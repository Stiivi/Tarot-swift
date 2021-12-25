//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

/// Node of a graph.
///
open class Node: Object {
    public var trait: Trait? = nil

    /// Returns related nodes to this node. Node relationshops are described in
    /// ``LinkTrait``.
    ///
    /// - Returns: List of nodes.
    ///
    public func related(_ linkName: String) -> [Node] {
        guard let graph = self.graph else {
            return []
        }
        guard let trait = self.trait else {
            // The node has no trait
            return []
        }
        guard let linkDesc = trait._links[linkName] else {
            // There is no such link description
            return []
        }
        
        let links: [Link]
        let nodes: [Node]
        
        // TODO: This is simplified matching
        let predicate = AttributeValuePredicate(key: "name",
                                                value: .string(linkDesc.linkName))
        
        if linkDesc.isReverse {
            links = graph.incoming(self).filter { predicate.matches($0) }
            nodes = links.map { $0.origin }
        }
        else {
            links = graph.outgoing(self).filter { predicate.matches($0) }
            nodes = links.map { $0.target }
        }
        
        return nodes
    }
}
