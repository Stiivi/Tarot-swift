//
//  GraphMemory.swift
//
//
//  Created by Stefan Urbanek on 2021/10/5.
//

// FIXME: We are importing Records only because of Value
import Records

// FIXME: Any use of this library should belong to an extension
import Combine

/// Protocol for a basic graph memory implementation. This protocol is
/// a scaffolding for development - it helps to separate interface from the
/// implementaiton.
///
public protocol GraphMemoryProtocol {
    var nodes: Set<Node> { get }
    var links: Set<Link> { get }

    /// Create a new empty node in the graph.
    func add(_ node: Node)
    
    /// Removes existing node and removes all links that are incoming or
    /// outgoing from the node.
    func remove(_ node: Node)
    
    /// Create a link in the memory.
    func connect(from origin:Node, to target:Node, attributes:[String:Value]) -> Link
    /// Remove a link from the memory
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


/// Graph Memory is a mutable graph container. It contains nodes and links and
/// provides functionality for modifying the graph.
///
///
/// # Example
///
/// ```swift
/// let memory = GraphMemory()
///
/// let parent = Node()
/// memory.add(parent)
///
/// let leftChild = Node()
/// memory.add(leftChild)
/// memory.connect(from: parent, to: leftChild, at: "left")
///
/// let rightChild = Node()
/// memory.add(rightChild)
/// memory.connect(from: parent, to: leftChild, at: "right")
/// ```
///
/// - Remark: For engineers out there: This is a "domain specific problem environment object", or a
/// "simulation environment". It is not made a generic as it is not intended
/// for general purpose use. It does not mean it might not change in the future.
///
public class GraphMemory: GraphMemoryProtocol {
    
    /// Mapping between node IDs and node objects.
    private var nodeIndex: [OID:Node] = [:]
    
    /// Mapping between link IDs and link objects.
    private var linkIndex: [OID:Link] = [:]
    
    /// Sequence for generating graph object IDs.
    private var idSequence: Int = 1
    
    
    /// An object that will receive notifications on changes in the graph.
    ///
    public var delegate: GraphMemoryDelegate? = nil
    
    /// Create an empty graph memory.
    ///
    public init() {
        self.nodeIndex = [:]
        self.linkIndex = [:]
    }
    
    private func nextID() -> OID {
        let id = idSequence
        idSequence += 1
        return id
    }
    
    // FIXME: Is this really needed?
    /// Get a graph object by its ID. The object can be either a node or a link.
    public func object(_ oid: OID) -> Object? {
        return nodeIndex[oid] ?? linkIndex[oid]
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
        guard node.id == nil else {
            fatalError("Trying to associate a node with non-empty id: \(node)")
        }
        let id = nextID()
        
        // Register the object
        node.graph = self
        node.id = id

        nodeIndex[id] = node
        
        delegate?.graph(self, didAdd: node)
    }
    /// Removes node from the space and removes all incoming and outgoing links
    /// for that node.
    ///
    public func remove(_ node: Node) {
        guard node.graph === self else {
            fatalError("Trying to dissociate a node from another memory")
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
        print("--- graph: removing node \(node.id)")
        node.id = nil

        delegate?.graph(self, didRemove: node)
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
    ///
    /// - Returns: Newly created link
    ///
    @discardableResult
    public func connect(from origin: Node, to target: Node, attributes: [String:Value]=[:]) -> Link {
        let linkID = nextID()
        let link = Link(id: linkID, origin: origin, target: target)
        self.linkIndex[linkID] = link
        
        for item in attributes {
            link[item.key] = item.value
        }
        delegate?.graph(self, didConnect: link)
        return link
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
        guard let id = link.id else {
            fatalError("Trying to remove unassociated link: \(link)")
        }
        guard linkIndex[id] != nil else {
            fatalError("Trying to remove unknown link: \(link)")
        }
        self.linkIndex[id] = nil
        delegate?.graph(self, didDisconnect: link)
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

    /// Determines whether the `node` is an orphan, that is whether the node has
    /// no incoming neither outgoing links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isOrphan(_ node: Node) -> Bool {
        let flag: Bool
        
        // Check whether there exists at least one link of which the `node`
        // is an origin or a target.
        //
        flag = links.contains {
            $0.origin === node || $0.target === node
        }
        
        return flag
    }
    
}

extension GraphMemory: CustomStringConvertible {
    public var description: String {
        "GraphMemory(nodes: \(nodes.count), links: \(links.count))"
    }
}
