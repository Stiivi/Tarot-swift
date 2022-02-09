//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 07/02/2022.
//

import Records

/// Node that represents an attribute description.
public class Model: BaseNodeProjection {
    // TODO: Rething this container: indexed? keyed? keyed with order? why?
    
    /// Indexed neighbourhood with nodes representing attributes that are
    /// relevant to a graph.
    ///
    public var attributes: IndexedCollection {
        return IndexedCollection(representedNode,
                                 selector:LinkSelector("attribute"))
    }
    
    /// Returns a first attribute with given name
    public func firstAttribute(name: String) -> AttributeDescription? {
        // TODO: Still wondering whether we should rather use keyed collecition
        let link = attributes.links.first {
            // TODO: Use AttributeDescription here
            $0.target["name"]?.stringValue() == name
        }
        
        if let link = link {
            return AttributeDescription(link.target)
        }
        else {
            return nil
        }
        
    }
}
