//
//  Traits.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/6.
//

// TODO: traits are not final idea, they are planned to be redesigned

/*
   Explanation:
 
    - Trait is semantics
    - [future] Objects can have multiple traits
    - [future] Objects can change traits
    - [future] Traits will serve also as constraints
 
*/

import Records


/// `Trait` describes properties and links of a node.
///
public final class Trait {
    
    /// Trait name.
    ///
    public let name: String
    var _links: [String:LinkDescription]
    var _attributes: [String:AttributeDescription]
    
    /// List of link descriptions. Links described here have a special meaning
    /// for nodes of this trait. Although it does not mean that the node might
    /// not have other kinds of links.
    ///
    public var links: [LinkDescription] { return Array(_links.values) }
    
    /// List of attribute descriptions. Attributes described here have a
    /// specific meaning for nodes of this trait. Although nodes might have
    /// other attributes set as well.
    ///
    public var attributes: [AttributeDescription] { return Array(_attributes.values) }

    /// Creates a trait with given name, list of link descriptions and
    /// attribute descriptions.
    ///
    /// - Parameters:
    ///   - name: Trait name. It is expected to be unique within a model.
    ///   - links: List of link descriptions.
    ///   - attributes: List of attribute descriptions.
    ///
    public required init(name: String, links: [LinkDescription]=[],
                attributes: [AttributeDescription]=[]) {
        self.name = name
        self._links = [:]
        self._attributes = [:]
        
        for link in links {
            self._links[link.name] = link
        }
        for attr in attributes {
            self._attributes[attr.name] = attr
        }
    }
    
    /// Get a property description by name.
    ///
    public func property(name: String) -> AttributeDescription? {
        return _attributes[name]
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
