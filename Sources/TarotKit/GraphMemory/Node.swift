//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

// TODO: The Traits are not final, still under design and consideration.

/// Object representing a node of a graph.
///
open class Node: Object {
    public var trait: Trait? = nil
}


/// Convenience methods that forward to the graph memory.
///
extension Node {
    /// Flag whether the node has no outgoing links.
    /// See ``GraphMemory/isSink(_:)`` for more information.
    public var isSink: Bool  { graph!.isSink(self) }

    /// Flag whether the node has no incoming links.
    /// See ``GraphMemory/isSource(_:)`` for more information.
    public var isSource: Bool  { graph!.isSource(self) }

    /// Flag whether the node has no links associated with it.
    /// See ``GraphMemory/isOrphan(_:)`` for more information.
    public var isOrphan: Bool  { graph!.isOrphan(self) }
}
