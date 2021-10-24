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
    
    subscript(member: String) -> [Node]? {
        guard let space = self.graph else {
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
        
        let nodes: [Node]
        
        if linkDesc.isReverse {
            nodes = space.incoming(self).map { $0.origin }
        }
        else {
            nodes = space.outgoing(self).map { $0.target }
        }
        
        return nodes
    }

}
