//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/04/2022.
//

import Foundation


extension Node {
    
    var _traitHood: NeighbourhoodOfOne {
        NeighbourhoodOfOne(self, selector:LinkSelector("trait"))
    }
    
    /// Get node trait, if it is associated with it.
    ///
    public var trait: Trait? {
        if let node = _traitHood.node {
            return Trait(node)
        }
        else {
            return nil
        }
    }

    /// Set node trait.
    ///
    /// This method connects the node with the trait. The optional ``attributes``
    /// are added to the newly created link.
    ///
    public func setTrait(_ trait: Trait, attributes: AttributeDictionary=[:]) {
        _traitHood.set(trait.representedNode, attributes: attributes)
    }
    
    /// Removes node trait.
    ///
    public func removeTrait() {
        _traitHood.remove()
    }
    
    /// Get a named neighbourhood for the node.
    ///
    public func neighbourhood(_ name: String) -> LabelledNeighbourhood? {
        guard let trait = self.trait else {
            return nil
        }
        guard let hoodTraitNode = trait.neighbourhoods[name] else {
            return nil
        }
        let hoodTrait = NeighbourhoodTrait(hoodTraitNode)
        return hoodTrait.neighbourhood(in: self)
    }
}
