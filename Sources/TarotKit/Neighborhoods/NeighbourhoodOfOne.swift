//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/04/2022.
//

import Foundation

/// A neighbourhood that assumes that there is only one link that matches the
/// provided ``LinkSelector`` as ``selector``.
///
/// If there are multiple links with given selector, then one is provided
/// arbitrarily.
///
public class NeighbourhoodOfOne: LabelledNeighbourhood {
    /// Returns a link that matches the neighbourhood link selector.
    ///
    /// If multiple links exist, then just one is returned arbitrarily.
    ///
    public var link: Link? {
        return links.first
    }
    
    /// Returns a node that is a target of a single link that matches the
    /// neighbourhood link selector.
    ///
    /// If multiple nodes exist, then just one is returned arbitrarily.
    ///
    public var node: Node? {
        return nodes.first
    }
    
    @discardableResult
    public func set(_ node: Node, attributes: AttributeDictionary=[:]) -> Link {
        disconnectAll()
        return add(node, attributes: attributes)
    }
    
    public func remove() {
        disconnectAll()
    }
}
