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
    // TODO: Rething this container: indexed? keyed? keyed with order? why?
    
    public var _attributesHood: IndexedCollection {
        IndexedCollection(representedNode, selector:LinkSelector("attribute"))
    }
    
    /// Indexed neighbourhood with nodes representing attributes that are
    /// relevant to a graph.
    ///
    public var attributes: [AttributeDescription] {
        return _attributesHood.nodes.map { AttributeDescription($0) }
    }
    
    /// Returns a first attribute with given name
    public func firstAttribute(name: String) -> AttributeDescription? {
        // TODO: Still wondering whether we should rather use keyed collecition
        let attr = attributes.first { $0.name == name }
        
        if let attr = attr {
            return attr
        }
        else {
            return nil
        }
        
    }
    
    /// Add an attribute to the model.
    ///
    /// - ToDo: This is a draft
    ///
    public func addAttribute(_ node: Node) {
        _attributesHood.append(node)
    }
}
