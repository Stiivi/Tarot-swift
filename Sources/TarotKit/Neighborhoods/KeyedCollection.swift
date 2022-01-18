//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/01/2022.
//

import Records


/// View of a node that represents a dictionary. KeyedCollection is a collection
/// node where items can be assigned a key. Key is a property of a link and is
/// unique for the dictionary.
///
// TODO: Rename to KeyedNeighbourhood
public class KeyedCollection: LabelledNeighbourhood {
    /// Name of an attribute that belongs to a link refering to a dictionary
    /// node. The value of the attribute is a key that is used to lookup the
    /// node. Default is `key`.
    ///
    /// The dictionary projection manages the represented node in a way that
    /// only one link with given key should exist at a time.
    ///
    public let linkKeyAttribute: String
    
    /// Creates a projection for a dictionary.
    ///
    public init(_ node: Node, selector: LinkSelector, keyAttribute: String = "key") {
        self.linkKeyAttribute = keyAttribute
        super.init(node, selector: selector)
    }

    /// List of keys in the dictionary.
    ///
    public var keys: [Value] {
        let keys = links.compactMap {
            $0[linkKeyAttribute]
        }
        
        return Array(Set(keys))
    }
    
    
    /// Get a node with key `key` in the dictionary. If multiple keys exist then
    /// returns one arbitrarily.
    ///
    /// - Note: Multiple keys might exist if the links were created in some
    ///         other way than using this dictionary.
    public func node(forKey key: Value) -> Node? {
        let link = links.first {
            $0[linkKeyAttribute] == key
        }
        
        return link.map { $0.target }
    }

    /// Remove a key from the dictionary. All links from the neighborhood
    /// that are outgoing from the represented node and have a key `key` are
    /// removed.
    ///
    /// - Note: Multiple keys might exist if the links were created in some
    ///         other way than using this dictionary.
    ///
    public func removeNode(forKey key: Value) {
        for link in self.links {
            if link[linkKeyAttribute] == key {
                link.graph?.disconnect(link: link)
            }
        }
    }

    /// Add a node to the dictionary with a key `key`.
    ///
    /// This method removes all existing dictionary entries with the key before
    /// creating a new link. See ``KeyedCollection/removeKey()`` for more
    /// information.
    ///
    public func setNode(_ node: Node, forKey key: Value,
                        attributes: [String:Value] = [:]) {
        var linkAttributes = attributes
        linkAttributes[linkKeyAttribute] = key
        removeNode(forKey: key)
        self.add(node, attributes:linkAttributes)
    }
    
    public subscript(key: Value) -> Node? {
        get { node(forKey: key) }
        set(node) {
            if let node = node {
                setNode(node, forKey: key)
            }
            else {
                removeNode(forKey: key)
            }
        }
    }
}
