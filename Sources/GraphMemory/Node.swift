//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

/// Node of a graph.
///
@dynamicMemberLookup
open class Node: Object {
    var trait: Trait? = nil

    subscript(dynamicMember member: String) -> [Node]? {
        return self[member]
    }
   
    // TODO: Consider changing this to be a non-optional
    subscript(member: String) -> [Node]? {
        guard let graph = self.graph else {
            return nil
        }
        guard let trait = self.trait else {
            // The node has no trait
            return nil
        }
        guard let linkDesc = trait._links[member] else {
            // There is no such link description
            return nil
        }
        
        let links: [Link]
        let nodes: [Node]
        
        // TODO: This is simplified matching
        let predicate = AttributeValuePredicate(key: "name",
                                                value: .string(linkDesc.linkName))
        
        if linkDesc.isReverse {
            links = graph.incoming(self).filter { predicate.evaluate($0) }
            nodes = links.map { $0.origin }
        }
        else {
            links = graph.outgoing(self).filter { predicate.evaluate($0) }
            nodes = links.map { $0.target }
        }
        
        return nodes
    }
}
