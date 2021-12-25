//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/5.
//

import Foundation

// TODO: We are separating trait-related code here

/*
 
 # Development Notes
 
 Potential object semantics might be one or multiple of the following:
 
 - Trait – each node can have multiple traits
    - unspecified whether namespace is overlapping or not
 - Protocol – each node can have multiple protocols
    - overlapping namespace
 - Class – each node can have one class
    -> It is Trait + constraint on number of traits
 - Entity-Component
    - one namespace per component

 */
 
import Records

extension GraphMemory {
    
    // TODO: This is just a convenience method
    /// Find nodes with given trait name
    public func filter(traitName: String) -> [Node]{
        return nodes.filter { node in
            if let trait = node.trait {
                return trait.name == traitName
            }
            else {
                return false
            }
        }
        
    }
    
    // TODO: This is just a convenience method
    /// Creates a link (oriented edge) between two nodes, from `origin` to
    /// `target`. The link name is used to reference to the link from nodes
    /// and other contexts.
    ///
    /// The link name does not have to be unique and there might be multiple
    /// links with the same name between two nodes.
    ///
    /// Link name is being used in fetching traits related relationships.
    ///
    /// - Parameters:
    ///
    ///     - origin: The node from which the link originates.
    ///     - target: The node to which the link points.
    ///     - name: Name of the link.
    ///
    /// - Returns: Newly created link
    ///
    @discardableResult
    public func connect(from origin: Node, to target: Node, at name: String) -> Link {
        let link = connect(from: origin, to: target)
        link["name"] = .string(name)

        return link
    }
}
