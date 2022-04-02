//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/04/2022.
//

import Foundation


/// A node projection that describes features of a node.
///
/// Traits describe node's attributes and neighbourhoods.
///
public class Trait: BaseNodeProjection, Equatable {
    // TODO: This is not used, remove.
    /// Trait name
    public var name: String? {
        get {
            representedNode["name"]?.stringValue()
        }
        set(value) {
            representedNode["name"] = value.map { .string($0) }
        }
    }
    
    /// Dictionary of associated neighbourhood traits. See ``NeighbourhoodTrait``
    /// for more information.
    ///
    public var neighbourhoods: KeyedNeighbourhood {
        KeyedNeighbourhood(representedNode, selector:LinkSelector("neighbourhood"))
    }
    
    
    var _nodesHood: LabelledNeighbourhood {
        LabelledNeighbourhood(representedNode,
                              selector: LinkSelector("trait", direction: .incoming))
    }
    
    /// All nodes with this trait.
    ///
    public var nodes: [Node] {
        return _nodesHood.nodes
    }
    
    public static func ==(lhs: Trait, rhs: Trait) -> Bool {
        return lhs.representedNode === rhs.representedNode
    }
}
