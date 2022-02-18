//
//  Graph.swift
//
//
//  Created by Stefan Urbanek on 2021/10/5.
//

// -------------------------------------------------------------------------
// IMPORTANT: This is the core structure of this framework. Be very considerate
//            when adding new functionality. If functionality can be achieved
//            by using existing functionality, then add it to an extension
//            (file Graph+Convenience or similar). Optimisation is not
//            a reason to add functionality here at this moment.
// -------------------------------------------------------------------------

// STATUS: Happy

// FIXME: We are importing Records only because of Value
// TODO: Move Value functionality from Records to this module
import Records
import Combine

/// Protocol for a basic graph implementation. This protocol is
/// a scaffolding for development - it helps to separate interface from the
/// implementaiton.
///
public protocol GraphProtocol {
    // TODO: Now unused, should be removed?
    // TODO: There is add(Node) but no add(Link)
    // TODO: There is connect(...) as a creation method but not add(Link)
    // TODO: There is connect(...) as a creation method but not createNode(...)
    // TODO: Rename this to remove(Link) to be consistent with remove(Node)
 
    var nodes: Set<Node> { get }
    var links: Set<Link> { get }

    /// Create a new empty node in the graph.
    func add(_ node: Node)
    
    /// Removes existing node and removes all links that are incoming or
    /// outgoing from the node.
    func remove(_ node: Node)
    
    /// Create a link in the graph.
    func connect(from origin:Node, to target:Node, attributes:[AttributeKey:AttributeValue]) -> Link
    /// Remove a link from the graph
    func disconnect(link: Link)
    
//    /// Set attribute of a node. Return previous attribute value.
//    func setAttribute(node: Node, attribute: String, value: Value) -> Value?
//    /// Remove a node attribute if exists. Returns previous value if it was set or
//    /// nil when there was no value set for the attribute.
//    func removeAttribute(node: Node, attribute: String) -> Value?
//
//    /// Set attribute of a link. Return previous attribute value.
//    func setAttribute(link: Link, attribute: String, value: Value) -> Value?
//
//    /// Remove a link attribute if exists. Returns previous value if it was set or
//    /// nil when there was no value set for the attribute.
//    func removeAttribute(link: Link, attribute: String) -> Value?
}


// NOTE: Status: Stable
/// Graph is a mutable structure representing a directed labelled multi-graph.
/// The graph is composed of nodes (vertices) and links (edges between
/// vertices).
///
/// The main functionality of the graph structure is to mutate the graph:
/// ``Graph/add(_:)``, ``Graph/connect(from:to:attributes:)-372gc``.
///
/// # Example
///
/// ```swift
/// let graph = Graph()
///
/// let parent = Node()
/// graph.add(parent)
///
/// let leftChild = Node()
/// graph.add(leftChild)
/// graph.connect(from: parent, to: leftChild, at: "left")
///
/// let rightChild = Node()
/// graph.add(rightChild)
/// graph.connect(from: parent, to: leftChild, at: "right")
/// ```
///
/// - Remark: This is a "domain specific problem environment object", or a
/// "simulation environment". It is not made a generic as it is not intended
/// for general purpose use. It does not mean it might not change in the future.
///
public class Graph {
    /// Mapping between node IDs and node objects.
    private var nodeIndex: [OID:Node] = [:]
    
    /// Mapping between link IDs and link objects.
    private var linkIndex: [OID:Link] = [:]
    
    /// ID generator for graph objects created by the graph.
    private var idGenerator: UniqueIDGenerator
    
    var _publisher: PassthroughSubject<GraphChange, Never>? = nil

    /// Publisher for graph changes
    var publisher: PassthroughSubject<GraphChange, Never> {
        if _publisher == nil {
            _publisher = PassthroughSubject<GraphChange, Never>()
        }
        return _publisher!
    }
    
    /// Create an empty graph.
    ///
    /// - Parameters:
    ///   - idGenerator: Generator of unique IDs. Default is ``SequenceIDGenerator``.
    ///
    public init(idGenerator: UniqueIDGenerator=SequenceIDGenerator()) {
        self.idGenerator = idGenerator
        self.nodeIndex = [:]
        self.linkIndex = [:]
    }
    
    /// Get a node by its ID. Returns `nil` if there is no node with the id
    /// in the graph.
    ///
    public func node(_ oid: OID) -> Node? {
        return nodeIndex[oid]
    }

    /// Get a link by its ID. Returns `nil` if there is no link with the id in
    /// the graph.
    ///
    public func link(_ oid: OID) -> Link? {
        return linkIndex[oid]
    }

    /// Read-only collection of all nodes in the graph.
    ///
    public var nodes: Set<Node> {
        return Set(nodeIndex.values)
    }
    
    /// Read-only collection of all links in the graph.
    ///
    public var links: Set<Link> {
        return Set(linkIndex.values)
    }
    
    /// Adds a node to the graph.
    ///
    /// - Note: A node belongs to one graph only. It can not be shared once
    /// added to a graph.
    ///
    /// - Parameters:
    ///
    ///     - node: Node to be added to the graph.
    ///
    public func add(_ node: Node) {
        guard node.graph == nil else {
            fatalError("Trying to associate already associated node: \(node)")
        }
        if let id = node.id {
            guard nodeIndex[id] == nil else {
                fatalError("Trying to associate a node with id that already exists: \(id)")
            }
            idGenerator.markUsed(id)
        }
        else {
            node.id = idGenerator.next()
        }
        
        // Register the object
        node.graph = self

        nodeIndex[node.id!] = node
        
        let change = GraphChange.addNode(node)
        didChange(change)
    }
    
    /// Removes node from the graph and removes all incoming and outgoing links
    /// for that node.
    ///
    // TODO: We need to distinguish between removing the nodes and unlinking the nodes
    public func remove(_ node: Node) {
        // TODO: This should be more atomic and shuold not remove a node if there are any links
        guard node.graph === self else {
            fatalError("Trying to dissociate a node from another graph")
        }
        guard let oid = node.id else {
            fatalError("Trying to dissociate a node without id")
        }
        
        // First we remove all the conections
        for link in links {
            if link.origin === node || link.target === node {
                disconnect(link: link)
            }
        }
        // FIXME: Check for in/out links
        nodeIndex[oid] = nil

        node.graph = nil

        let change = GraphChange.removeNode(node)
        didChange(change)
    }
    
    /// Tests whether the graph contains a node.
    ///
    /// - Returns: `true` if the graph contains `node`
    ///
    public func contains(node: Node) -> Bool {
        guard let id = node.id else {
            return false
        }
        return self.nodeIndex[id] != nil
    }
    
    ///
    /// The link name does not have to be unique and there might be multiple
    /// links with the same name between two nodes.
    ///
    /// - Parameters:
    ///
    ///     - origin: The node from which the link originates.
    ///     - target: The node to which the link points.
    ///     - attributes: Attributes of the link.
    ///     - id: Unique link identifier. Link with given identifier must not
    ///     exist. If not provided, new one is assigned.
    ///
    /// - Returns: Newly created link
    ///
    @discardableResult
    public func connect(from origin: Node, to target: Node, attributes: [AttributeKey:AttributeValue]=[:], id: OID?=nil) -> Link {
        guard origin.graph === self else {
            if origin.graph == nil {
                fatalError("Connecting to a non-associated origin")
            }
            else {
                fatalError("Connecting from an origin from a different graph")
            }
        }
        guard target.graph === self else {
            if target.graph == nil {
                fatalError("Connecting to a non-associated target")
            }
            else {
                fatalError("Connecting to a target from a different graph")
            }
        }
        
        let linkID: OID

        if let id = id {
            guard linkIndex[id] == nil else {
                fatalError("Link with id '\(id)' already exists.")
            }
            guard nodeIndex[id] == nil else {
                fatalError("Link id '\(id)' is already assigned to a node.")
            }
            linkID = id
            idGenerator.markUsed(id)
        }
        else {
            linkID = idGenerator.next()
        }
        
        let link = Link(id: linkID, origin: origin, target: target)
        link.graph = self
        self.linkIndex[linkID] = link
        
        for item in attributes {
            link[item.key] = item.value
        }
        
        let change = GraphChange.connect(link)
        didChange(change)

        return link
    }
    
    /// Adds a custom-created link to the graph.
    ///
    /// This method can be also used to associate previously associated link
    /// with the graph. Typical use-case would be an undo command.
    /// 
    /// - Note: A link object belongs to one graph only. It can not be shared
    /// once added to a graph.
    ///
    /// - Parameters:
    ///
    ///     - link: Link to be added to the graph.
    ///
    public func add(_ link: Link) {
        guard link.graph == nil else {
            fatalError("Trying to associate already associated link: \(link)")
        }
        if let id = link.id {
            guard linkIndex[id] == nil else {
                fatalError("Trying to associate a link with id that already exists: \(id)")
            }
            idGenerator.markUsed(id)
        }
        else {
            link.id = idGenerator.next()
        }
        
        // Register the object
        link.graph = self

        linkIndex[link.id!] = link
        
        let change = GraphChange.connect(link)
        didChange(change)
    }

    
//    Note: We can not disconnect all of links between two nodes as it is
//          not a simple operation that can have an easy reversal.
//
//    /// Removes all links between node `origin` and `target`.
//    ///
//    /// To remove a specific link use ``remove(link:)``.
//    ///
//    /// - Parameters:
//    ///
//    ///     - origin: The node from which the link originates.
//    ///     - target: The node to which the link points.
//    ///
//    public func disconnect(from origin: Node, to target: Node) {
//        let toRemove: [Link]
//
//        toRemove = self.linkIndex.values.filter { link in
//            link.origin === origin && link.target === target }
//
//        for link in toRemove {
//            remove(link: link)
//        }
//    }
    
    /// Removes a specific link from the graph. Link must exist in the graph.
    ///
    /// - Parameters:
    ///
    ///     - link: Link to be removed.
    ///
    public func disconnect(link: Link) {
        guard link.graph === self else {
            fatalError("Disconnecting a link from a different graph")
        }
        
        guard let id = link.id else {
            fatalError("Trying to remove unassociated link: \(link)")
        }
        guard linkIndex[id] != nil else {
            fatalError("Trying to remove unknown link: \(link)")
        }
        self.linkIndex[id] = nil
        link.graph = nil

        let change = GraphChange.disconnect(link)
        didChange(change)
    }
    
    /// Get a list of outgoing links from a node.
    ///
    /// - Parameters:
    ///     - origin: Node from which the links originate - node is origin
    ///     node of the link.
    ///
    /// - Returns: List of links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///
    public func outgoing(_ origin: Node) -> [Link] {
        let result: [Link]
        
        result = self.linkIndex.values.filter {
            $0.origin === origin
        }

        return result
    }
    /// Get a list of links incoming to a node.
    ///
    /// - Parameters:
    ///     - target: Node to which the links are incoming – node is a target
    ///       node of the link.
    ///
    /// - Returns: List of links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///
    public func incoming(_ target: Node) -> [Link] {
        let result: [Link]
        
        result = self.linkIndex.values.filter {
            $0.target === target
        }

        return result
    }
    
    /// Get a list of links that are related to the neighbors of the node. That
    /// is, list of links where the node is either an origin or a target.
    ///
    /// - Returns: List of links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///
    public func neighbors(_ node: Node) -> [Link] {
        let result: [Link]
        
        result = self.linkIndex.values.filter {
            $0.target === node || $0.origin === node
        }

        return result
    }
    
    /// Determines whether the node has no outgoing links. That is, if there
    /// are no links which have the node as origin.
    ///
    /// - Returns: `true` if there are no outgoing links from the node.
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isSink(_ node: Node) -> Bool {
        guard node.graph === self else {
            fatalError("Node is not associated with this graph.")
        }
        return links.contains { $0.origin === node }
    }
    
    /// Determines whether the node has no incoming links. That is, if there
    /// are no links which have the node as target.
    ///
    /// - Returns: `true` if there are no incoming links to the node.
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isSource(_ node: Node) -> Bool {
        guard node.graph === self else {
            fatalError("Node is not associated with this graph.")
        }
        return links.contains { $0.target === node }
    }
    
    /// Determines whether the `node` is an orphan, that is whether the node has
    /// no incoming neither outgoing links.
    ///
    /// - Returns: `true` if there are no links referring to the node.
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isOrphan(_ node: Node) -> Bool {
        guard node.graph === self else {
            fatalError("Node is not associated with this graph.")
        }
        return links.contains { $0.origin === node || $0.target === node }
    }
    
    /// Called when graph has changed.
    func didChange(_ change: GraphChange) {
        publisher.send(change)
    }
}


extension Graph: CustomStringConvertible {
    public var description: String {
        "Graph(nodes: \(nodes.count), links: \(links.count))"
    }
}
