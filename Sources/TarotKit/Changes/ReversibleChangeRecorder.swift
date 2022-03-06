//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 23/02/2022.
//

import Foundation
import Records

/// Object that observes changes to the graph and provides a list of changes
/// to undo recorded changes.
///
/// - Note: This is preliminary implementation of an undo/redo backend.
///
public class ReversibleChangeRecorder {
    // TODO: Make this use DetachedNode and DetachedLink
    // TODO: Rename to GraphChangeManager and keep record of all the changes
    let graph: Graph
    
    public init(graph: Graph) {
        self.graph = graph
    }
    
    /// Record changes applied to a graph.
    ///
    /// Record changes:
    ///
    /// ```swift
    /// let recorder = ReversibleChangeRecorder(graph: graph)
    /// let node = Node()
    ///
    /// let changes = recorder.record {
    ///     graph.add(node)
    /// }
    ///
    /// ```
    ///
    /// Revert changes:
    ///
    /// ```swift
    /// for change in changes {
    ///     graph.applyChange(change)
    /// }
    /// ```
    ///
    /// - Attention: When there are any changes applied to the graph between the
    ///   recording and reverting the changes, then the behaviour is undefined
    ///   and might even result in a fatal error.
    ///
    /// - Returns: Changes, that when applied in order as returned, will
    ///   revert the graph to the state prior to the recording.
    ///
    public func record(activity: () -> Void) -> [GraphChange] {
        var observer: GraphObserver! = nil
        var changes: [GraphChange] = []
        
        observer = graph.graphWillChange.sink { change in
            switch change {
            // Observed changes
            case let .addNode(node):
                changes.append(.removeNode(node))
                
            case let .removeNode(node):
                let restoreLinks: [GraphChange] = node.neighbours.map { .connect($0) }

                changes += restoreLinks
                changes.append(.addNode(node))
            case let .connect(link):
                changes.append(.disconnect(link))

            case let .disconnect(link):
                changes.append(.connect(link))

            case let .setAttribute(object, attribute, _):
                let reverse: GraphChange
                if let value = object[attribute] {
                    reverse = .setAttribute(object, attribute, value)
                }
                else {
                    reverse = .unsetAttribute(object, attribute)
                }
                changes.append(reverse)
                
            case let .unsetAttribute(object, attribute):
                let reverse: GraphChange
                if let value = object[attribute] {
                    reverse = .setAttribute(object, attribute, value)
                }
                else {
                    reverse = .unsetAttribute(object, attribute)
                }
                changes.append(reverse)
            }
        }

        activity()

        observer?.cancel()

        return changes.reversed()
    }
}
