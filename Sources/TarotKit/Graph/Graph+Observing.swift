//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 26/01/2022.
//

import Combine

// TODO: Wrap the combine in some API that can be replicated in other languages.

/// Publisher for graph changes
public typealias GraphChangePublisher = AnyPublisher<GraphChange, Never>
public typealias GraphObserver = Cancellable

extension Graph {
    /// Returns a publisher that publishes any changes made within the graph.
    ///
    public func observe() -> GraphChangePublisher {
        return GraphChangePublisher(self.publisher)
    }
    
    /// Returns a publisher that publishes structural changes to the graph.
    /// A structural change is a change that involves nodes and links: adding
    /// and removing a node, creating and disconnecting a link. Change of
    /// attributes is not a structural change.
    ///
    public func observeStructure() -> GraphChangePublisher {
        let publisher = self.publisher.filter {
            change in
            switch change {
            // Observed changes
            case .addNode: return true
            case .removeNode: return true
            case .connect: return true
            case .disconnect: return true
            // Not observed changes
            case .setAttribute: return false
            case .unsetAttribute: return false
            }
        }
        return GraphChangePublisher(publisher)
    }

    /// Returns a publisher for observing changes to attributes of a node or a
    /// link.
    ///
    public func observeAttributes(object observed: Object) -> GraphChangePublisher {
        let publisher = self.publisher.filter {
            change in
            switch change {
            case .setAttribute(let obj, _, _): return obj === observed
            case .unsetAttribute(let obj, _): return obj === observed
            default: return false
            }
        }
        return GraphChangePublisher(publisher)
    }
    
    /// Returns a publisher that observes changes to a neighbourhood of a node.
    /// Observed changes are creation or disconnection of a link where
    /// the node is either an origin or a target.
    ///
    public func observeNeighbourhood(node: Node) -> GraphChangePublisher {
        let publisher = self.publisher.filter {
            change in
            switch change {
            case .connect(let link): return link.origin === node || link.target === node
            case .disconnect(let link): return link.origin === node || link.target === node
            default: return false
            }
        }
        return GraphChangePublisher(publisher)
    }

    /// Returns a publisher that observes removal of a node.
    /// Observed changes are creation or disconnection of a link where
    /// the node is either an origin or a target.
    ///
    public func observeRemoval(node: Node) -> GraphChangePublisher {
        let publisher = self.publisher.filter {
            change in
            switch change {
            case .removeNode(let removedNode): return node === removedNode
            default: return false
            }
        }
        return GraphChangePublisher(publisher)
    }
}
