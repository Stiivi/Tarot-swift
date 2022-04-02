//
//  NodeProjection.swift
//  
//
//  Created by Stefan Urbanek on 02/01/2022.
//

import Foundation

// TODO: Add validation.

/*
 Validation:
 
 func validate() -> [ValidationIssue]
 
 struct ValidationIssue {
    let error: Error
    let description: String
    let suggestion: String
    let canBeAutofixed: Bool
 }
 
 */

/// Node projection is a kind of object that provides additional, more complex
/// operations on a `representedNode` node and its surroundings.
///
/// An example might be treating a node as if it represented a collection
/// of other nodes. The collection view might consider specific kinds of links
/// as references to collection's items.
///
public protocol NodeProjection {
    // TODO: Implement: neighbours(name: String) -> [Node]
    var representedNode: Node { get }
    
    /// Connect the represented node with a node `node` in a way that the
    /// connection follows the selector specification. Optional attributes
    /// can be set on the connection.
    ///
    /// For example if the selector specifies that the connection must have a
    /// label attribute `label` and value `item` where the direction is
    /// outgoing then a connection from the represented node to the given node
    /// is created. Attributes are copied and then value `item` is set for
    /// a key `label`.
    ///
    func connect(with node: Node, selector: LinkSelector, attributes: AttributeDictionary)
}

extension NodeProjection {
    public var graph: Graph? {
        return representedNode.graph
    }

    // TODO: This is the same as LabelledNeighbourhood.add(), probably remove this
    public func connect(with node: Node, selector: LinkSelector, attributes: AttributeDictionary = [:]) {
        var linkAttributes = attributes

        linkAttributes[selector.labelAttribute] = selector.label
        switch selector.direction {
        case .incoming: node.connect(to: representedNode, attributes: linkAttributes)
        case .outgoing: representedNode.connect(to: node, attributes: linkAttributes)
        }
    }
}

/// Convenience base class for concrete implementations of a custom node
/// projection.
///
open class BaseNodeProjection: NodeProjection {
    public var representedNode: Node
    
    public init(_ node: Node) {
        self.representedNode = node
    }
    public init(_ projection: NodeProjection) {
        self.representedNode = projection.representedNode
    }
}

/// Node is a projection of itself.
///
extension Node: NodeProjection {
    public var representedNode: Node { self }
}
