//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//


// TODO: Node should be in World, not Graph, so we can benefit from the semantics

/// Object representing a node of a graph.
///
public final class Node: Object {

    /// Links outgoing from the node, that is links where the node is the
    /// origin.
    ///
    /// It is empty when the node is not associated with a graph.
    ///
    /// - Note: If you want to get both outgoing and incoming links of a node
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///
    public var outgoing: [Link] {
        return graph!.outgoing(self)
    }

    /// Links incoming to the node, that is links where the node is the target.
    ///
    /// It is empty when the node is not associated with a graph.
    ///
    /// - Note: If you want to get both outgoing and incoming links of a node
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///
    public var incoming: [Link] {
        return graph!.incoming(self)
    }
    
    /// All the links that are associated somewhat with the node.
    ///
    /// It is empty when the node is not associated with a graph.
    ///
    public var neighbours: [Link] {
        return graph!.neighbours(self)
    }
    
    /// Connects the node to a `target` with optional attributes to be set
    /// on the newly created link.
    ///
    /// - Note: Does nothing when the node is not associated with a graph.
    ///
    @discardableResult
    public func connect(to target: Node, attributes: [AttributeKey:AttributeValue] = [:]) -> Link {
        return graph!.connect(from: self, to: target, attributes: attributes)
    }
    
    /// Flag whether the node has no outgoing links.
    /// See ``Graph/isSink(_:)`` for more information.
    public var isSink: Bool  { graph!.isSink(self) }

    /// Flag whether the node has no incoming links.
    /// See ``Graph/isSource(_:)`` for more information.
    public var isSource: Bool  { graph!.isSource(self) }

    /// Flag whether the node has no links associated with it.
    /// See ``Graph/isOrphan(_:)`` for more information.
    public var isOrphan: Bool  { graph!.isOrphan(self) }
}
