//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 30/12/2021.
//

import Foundation
import GraphMemory
import Records


// TODO: This is not clean - we should not assume the label to be "name"
extension Node {
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
        guard let linkDesc = trait.link(name: linkName) else {
            // There is no such link description
            return []
        }
        
        let links: [Link]
        let nodes: [Node]
        
        // TODO: This is simplified matching
        let labelKey = "name"
        let labelValue: Value = .string(linkDesc.linkName)
        
        if linkDesc.isReverse {
            links = graph.incoming(self).filter { $0[labelKey] == labelValue }
            nodes = links.map { $0.origin }
        }
        else {
            links = graph.outgoing(self).filter { $0[labelKey] == labelValue }
            nodes = links.map { $0.target }
        }
        
        return nodes
    }
}
