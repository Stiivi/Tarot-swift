//
//  ObjectSelection.swift
//  TarotKit
//
//  Created by Stefan Urbanek on 13/02/2022.
//

import Combine

/// Collection of selected graph objects.
///
/// The ``ObjectSelection`` is an object that contains a collection of graph
/// objects (links and/or nodes) and can publish changes to those objects.
///
/// - Note: Selection will not remove its objects when an object is removed
/// from the graph. It is up to the selection owner to do that.
///
public class ObjectSelection {
    /// Type for publisher of changes to the collection (not to the objects).
    ///
    public typealias Publisher = PassthroughSubject<Void, Never>

    /// Graph that owns the graph objects in the collection.
    ///
    public let graph: Graph

    /// Publisher for publishing changes of the selection objects. This
    /// publisher does not publish changes to the objects, neither any
    /// graph changes.
    ///
    let selectionPublisher: Publisher
    
    // TODO: The publisher is force-unwrap because its creation is required in init() where self needs to be captured. I do not know how to do it other way
    /// Publisher for publishing graph changes related to the selection of
    /// objects.
    ///
    /// This publisher does not publish changes to the selection.
    ///
    var graphChangePublisher: GraphChangePublisher!


    // TODO: Should we observe more detailed change? Like insertion, deletion, ...
    // TODO: Should we observe attributes here too?
    /// List of objects in the selection. Setting this property will trigger
    /// a message to be passed from the ``selectionPublisher``.
    ///
    /// To correctly observe changes to the object properties and their
    /// neighbourhoods, the objects must be associated with the graph
    /// of the selection object.
    ///
    /// - Note: the collection might contain objects that might have no graph
    /// associated with it. This might happen when an object was removed
    /// from the graph. Collection is not updated on such events.
    ///
    public var objects: [Object] {
        didSet {
            selectionPublisher.send()
        }
    }
    
    /// Number of objects in the selection.
    public var count: Int {
        return objects.count
    }
    
    /// Create a new selection with graph objects `objects` in the given
    /// document.
    ///
    public init(graph: Graph, objects: [Object]=[]) {
        self.graph = graph
        self.objects = objects
        self.selectionPublisher = PassthroughSubject<Void, Never>()
        self.graphChangePublisher = AnyPublisher(graph.observe().filter {
            change in
            self.objects.contains { change.isRelated($0) }
        })
    }
    
    /// Get the publisher for observing selection changes. The publisher
    /// emits a message when the ``objects`` property is set.
    ///
    public func observe() -> Publisher {
        return selectionPublisher
    }
    
    /// Returns a graph observer that observes attribute changes of objects in
    /// the selection.
    ///
    public func observeAttributes() -> GraphChangePublisher {
        let originalPublisher = graph.observe()
        
        let publisher = originalPublisher.filter { change in
            switch change {
            case let .setAttribute(object, _, _): return self.objects.contains(object)
            case let .unsetAttribute(object, _): return self.objects.contains(object)
            default: return false
            }
        }
        return GraphChangePublisher(publisher)
    }

    func observeRemoveObject() -> GraphChangePublisher {
        let originalPublisher = graph.observe()
        
        let publisher = originalPublisher.filter { change in
            switch change {
            case let .removeNode(node): return self.objects.contains(node)
            case let .disconnect(link): return self.objects.contains(link)
            default: return false
            }
        }
        return GraphChangePublisher(publisher)
    }

}

extension ObjectSelection: Collection {
    public func index(after i: Index) -> Index {
        objects.index(after: i)
    }
    
    public subscript(position: Index) -> Object {
        get { objects[position] }
    }
    
    public typealias Index = Array<Object>.Index
    
    public var startIndex: Index { objects.startIndex }
    public var endIndex: Index { objects.endIndex }
}
