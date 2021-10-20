//
//  GraphSpace.swift
//  Tarot
//
//  Created by Stefan Urbanek on 2021/10/5.
//

/// Graph Memory is a mutable graph container. It contains nodes and links and
/// provides functionality for modifying the graph.
///
public class GraphMemory {
    private var nodeIndex: [OID:Node] = [:]
    private var linkIndex: [OID:Link] = [:]
    private var idSequence: Int = 1

    public init() {
        self.nodeIndex = [:]
        self.linkIndex = [:]
    }
    
    public func nextID() -> OID {
        let id = idSequence
        idSequence += 1
        return id
    }
    
    var nodes: AnyCollection<Node> {
        return AnyCollection(nodeIndex.values)
    }
    
    var links: AnyCollection<Link> {
        return AnyCollection(linkIndex.values)
    }
    
    /// Associate programming language object structure with the memory.
    public func associate(_ node: Node) {
        guard node.space == nil else {
            fatalError("Trying to associate already associated node: \(node)")
        }
        guard node.id == nil else {
            fatalError("Trying to associate a node with non-empty id: \(node)")
        }
        let id = nextID()
        
        // Register the object
        node.space = self
        node.id = id

        nodeIndex[id] = node
    }
    /// Removes node from the space and removes all incoming and outgoing links
    /// for that node.
    ///
    public func remove(node: Node) {
        guard node.space === self else {
            fatalError("Trying to dissociate a node from another memory")
        }
        guard let oid = node.id else {
            fatalError("Trying to dissociate a node without id")
        }
        
        // First we remove all the conections
        for link in links {
            if link.origin === node || link.target === node {
                remove(link: link)
            }
        }
        // FIXME: Check for in/out links
        nodeIndex[oid] = nil

        node.space = nil
        node.id = nil
    }

    /// Returns `true` if the space contains `node`
    ///
    public func contains(node: Node) -> Bool {
        guard let id = node.id else {
            return false
        }
        return self.nodeIndex[id] != nil
    }
    
    @discardableResult
    public func connect(from origin: Node, to target: Node, at name: String) -> Link {
        let linkID = nextID()
        let link = Link(id: linkID, origin: origin, target: target, at: name)
        self.linkIndex[linkID] = link
        return link
    }
    
    public func disconnect(from origin: Node, to target: Node, at name: String) {
        let toRemove: [Link]
        
        toRemove = self.linkIndex.values.filter { link in
            link.origin === origin && link.target === target && link.name == name
        }
        
        for link in toRemove {
            remove(link: link)
        }
    }
    
    public func remove(link: Link) {
        guard let id = link.id else {
            fatalError("Trying to remove unassociated link: \(link)")
        }
        guard linkIndex[id] != nil else {
            fatalError("Trying to remove unknown link: \(link)")
        }
        self.linkIndex[id] = nil
    }
    
    /// Get a list of outgoing links for a node. The items are tuples
    /// `(name, Node)`
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
    /// Get a dictionary of incoming links for a node. The keys are link
    /// names and the values are nodes where the links originate"""
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
        
        flag = links.contains {
            $0.origin === node || $0.target === node
        }
        
        return flag
    }
}

