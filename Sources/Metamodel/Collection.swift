//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 26/12/2021.
//

import Foundation
import GraphMemory

extension GraphMemory {
    /// Create an ordered node collection
    public func orderedNodeCollection() -> [Node] {
       return []
    }
}

class ___Collection {
    /// Node representing the collection
    var node: Node
    /// Name of a link property to be looked at when locating collection
    /// members. Typically it would be `name`.
    ///
    let itemProperty: String
    
    /// Value of the item forming link property. Typically it would be `item`
    ///
    let linkPropertyValue: String
    let sortProperty: String?
    
    // TODO: NULLS FIRST/LAST
    
    /// Creates a collection rooted in `node`.
    ///
    public init(node: Node, itemProperty: String="name", itemPropertyValue: String="item",
                sortProperty: String?) {
        self.node = node
        self.itemProperty = itemProperty
        self.linkPropertyValue = itemPropertyValue
        self.sortProperty = sortProperty
    }
    
    var items: [Node] {
        guard let outgoing = node.graph?.outgoing(node) else {
            // FIXME: I guess this should be an error
            return []
        }
        var links: [Link] = outgoing.filter { link in
            link[itemProperty]?.stringValue() == linkPropertyValue
            }
        if let sortProperty = self.sortProperty {
            links.sort { left, right in
                guard let lhs = left[sortProperty] else {
                    return false
                }
                guard let rhs = right[sortProperty] else {
                    return false
                }
                return lhs.isLessThan(other: rhs)
                
            }
        }
        return links.map { $0.target }
    }
}
