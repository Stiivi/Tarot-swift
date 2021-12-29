//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/27.
//

import Foundation
import GraphMemory

/// Selection of nodes based on a predicate.
///
// We borrow the word "selection" from relational algebra. Although we are
// aware that it is not as pure as relational algebra's concept.
public class DynamicNodeCollection: RandomAccessCollection {
    public typealias Element = Node
    public typealias Index = Array<Node>.Index
    public typealias SubSequence = Array<Node>.SubSequence
    public typealias Indices = Array<Node>.Indices
    
    public let graph: GraphMemory
    public let predicate: ObjectPredicate
    public var _nodes: [Node]?

    public var nodes: [Node] {
        get {
            if let nodes = _nodes {
                return nodes
            }
            else {
                loadNodes()
                return _nodes!
            }
        }
    }
    
    public func loadNodes() {
        print("--- collection: reloading nodes")
        var nodes: [Node]
        nodes = graph.nodes.filter {
            predicate.matches($0)
        }
        // TODO: Add possibility to sort using other attributes
        nodes.sort { (lhs, rhs) in
                lhs.id! < rhs.id!
        }

//        objectWillChange.send()
        _nodes = nodes
    }
    
    public init(graph: GraphMemory, predicate: ObjectPredicate) {
        self.graph = graph
        self.predicate = predicate
        
        // FIXME: Use the result?
//        _ = self.graph.objectWillChange.sink(receiveValue: graphWillChange)
        loadNodes()
    }
    
    func graphWillChange() {
        // We just pass through the notification
        print("-- collection: graph changed")
   
        // invalidate nodes
        _nodes = nil
        loadNodes()
    }
    
    @discardableResult
    public func remove(at index: Index) -> Node {
        print("-- collection: will remove at: \(index)")
        let node = nodes[index]
        graph.remove(node)

        _nodes = nil
        loadNodes()
        print("-- collection: did remove")
        return node
    }

    // Random Access Collection
    // -------------------------------------------------------------
    
    public var startIndex: Index {
//        print("-- collection: get start index")
        return nodes.startIndex
    }
    public var endIndex: Index {
//        print("-- collection: get end index")
        return nodes.endIndex
    }
    
    public var indices: Indices {
        print("-- collection: get indices")
        return nodes.indices
    }

    public subscript(position: Index) -> Element {
        return nodes[position]
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
            return nodes[bounds]
    }

    
    public func index(after index: Index) -> Index {
        print("-- collection: get index after: \(index)")
        return nodes.index(after: index)
    }

}

