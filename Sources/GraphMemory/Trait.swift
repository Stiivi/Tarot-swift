//
//  Traits.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/6.
//

import Records

/// `LinkDescription` describes a link of a trait in a graph. It is used for
/// looking up links in either direction based on the `isReverse` attribute.
public final class LinkDescription {
    // TODO: Change isReverse into enum Direction { outgoing, incoming }
    // TODO: Consider renaming to 'LinkTrait'
    
    public let name: String
    // TODO: This is simplification for more complex predicate matching
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
    public required init(_ name: String, _ linkName: String, isReverse: Bool=false) {
        self.name = name
        self.linkName = linkName
        self.isReverse = isReverse
    }
}

extension LinkDescription: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case linkName
        case isReverse
    }
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let linkName = try container.decode(String.self, forKey: .linkName)
        let isReverse = try container.decodeIfPresent(Bool.self, forKey: .isReverse)
        self.init(name, linkName, isReverse: isReverse ?? false)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(linkName, forKey: .linkName)
        try container.encode(isReverse, forKey: .isReverse)
    }
}

/// Describes object property.
/// 
public final class PropertyDescription {
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
    public required init(_ name: String, label: String?=nil, valueType: ValueType = .string) {
        self.name = name
        self.label = label ?? name
        self.valueType = valueType
    }
}

extension PropertyDescription: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case label
        case valueType
    }
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let label = try container.decodeIfPresent(String.self, forKey: .label)
        let valueType = try container.decodeIfPresent(ValueType.self, forKey: .valueType)
        self.init(name, label: label ?? name, valueType: valueType ?? .string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(label, forKey: .label)
        try container.encode(valueType, forKey: .valueType)
    }
}


/// `Trait` describes properties and links of a node.
///
public final class Trait {
    public let name: String
    var _links: [String:LinkDescription]
    var _properties: [String:PropertyDescription]
    
    public var links: [LinkDescription] { return Array(_links.values) }
    public var properties: [PropertyDescription] { return Array(_properties.values) }

    public required init(name: String, links: [LinkDescription]=[],
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
    
    /// Get a property description by name.
    ///
    public func property(name: String) -> PropertyDescription? {
        return _properties[name]
    }
    
    /// Get a link description by name.
    ///
    public func link(name: String) -> LinkDescription? {
        return _links[name]
    }
}

extension Trait: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case _links = "links"
//        case _properties = properties
    }
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let links = try container.decodeIfPresent(Array<LinkDescription>.self, forKey: ._links)
        self.init(name: name, links: links ?? [])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(links, forKey: ._links)
    }
}
