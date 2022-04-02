//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 07/02/2022.
//

import Records

/// Node that represents an attribute description.
///
/// - ToDo: This is a draft
///
public class Model: BaseNodeProjection {
    // TODO: Rethink this container: indexed? keyed? keyed with order? why?
    
    public var _attributesHood: IndexedNeighbourhood {
        IndexedNeighbourhood(representedNode, selector:LinkSelector("attribute"))
    }
    
    /// Indexed neighbourhood with nodes representing attributes that are
    /// relevant to a graph.
    ///
    public var attributes: [AttributeDescription] {
        return _attributesHood.nodes.map { AttributeDescription($0) }
    }
    
    /// Returns a first attribute with given name
    public func firstAttribute(name: String) -> AttributeDescription? {
        // TODO: Still wondering whether we should rather use keyed collection
        let attr = attributes.first { $0.name == name }

        return attr
    }
    /// Add an attribute to the model.
    ///
    /// - ToDo: This is a draft
    ///
    public func addAttribute(_ node: Node) {
        _attributesHood.append(node)
    }
    

    /// A dictionary of traits.
    ///
    public var traits: KeyedNeighbourhood {
        KeyedNeighbourhood(representedNode, selector:LinkSelector("attribute"))
    }
}

