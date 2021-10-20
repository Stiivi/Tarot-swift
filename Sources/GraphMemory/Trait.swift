//
//  Traits.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/6.
//

import Records

/// `LinkDescription` describes a link of a trait in a graph. It is used for
/// looking up links in either direction based on the `isReverse` attribute.
public class LinkDescription {
    // TODO: Change isReverse into enum Direction { outgoing, incoming }
    // TODO: Consider renaming to 'LinkTrait'
    
    public let name: String
    public let linkName: String
    public let isReverse: Bool
    
    /// - Parameters:
    ///
    ///   - name: link name that will be used as an object attribute
    ///   - linkName: name of the link that is referred to by this description
    ///   - isReverse: flag whether we are looking at the reverse
    ///     relationship, that is we are looking at objects where the receiving
    ///     node is a target
    ///
    public init(_ name: String, _ linkName: String, isReverse: Bool=false) {
        self.name = name
        self.linkName = linkName
        self.isReverse = isReverse
    }
}

/// Describes object property.
/// 
public class PropertyDescription {
    public let name: String
    public let label: String
    public let valueType: ValueType
    
    /// Create a property description.
    ///
    /// - Parameters:
    ///
    ///   - name: property name that will be used as an object attribute.
    ///   - label: label of a link that is used for user interface. If not
    ///     provided then `name` will be used.
    ///   - valueType: type of the property value. Default is `string`
    ///
    public init(_ name: String, label: String?=nil, valueType: ValueType = .string) {
        self.name = name
        self.label = label ?? name
        self.valueType = valueType
    }
}

/// `Trait` describes properties and links of a node.
///
public class Trait {
    public let name: String
    var _links: [String:LinkDescription]
    var _properties: [String:PropertyDescription]
    
    public var links: [LinkDescription] { return Array(_links.values) }
    public var properties: [PropertyDescription] { return Array(_properties.values) }

    public init(name: String, links: [LinkDescription]=[],
                properties: [PropertyDescription]=[]) {
        self.name = name
        self._links = [:]
        self._properties = [:]
        
        for link in links {
            self._links[link.name] = link
        }
        for property in properties {
            self._properties[property.name] = property
        }
    }
}
