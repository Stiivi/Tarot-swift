//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/01/2022.
//

import Foundation


/// View of a node that represents a dictionary. Dictionary is a collection
/// node where items can be assigned a key. Key is a property of a link and is
/// unique for the dictionary.
///
public class Dictionary: Collection {
    /// Attribute of a link that contains a dictionary lookup key. Default is
    /// `key`.
    ///
    var keyLinkAttribute: String  { representedNode["keyLinkAttribute"]?.stringValue() ?? "key"}
    
    /// List of keys in the dictionary
    public var keys: [String] {
        let keys = itemLinks.compactMap {
            $0[keyLinkAttribute]?.stringValue()
        }
        
        return keys
    }
    
    
    /// Get a node named `name` in the dictionary.
    ///
    public func item(key: String) -> Node? {
        let link = itemLinks.first {
            $0[keyLinkAttribute]?.stringValue() == key
        }
        
        return link.map { $0.target }
    }

    /// Remove a name from the dictionary.
    ///
    public func removeKey(_ key: String) {
        let links = itemLinks.filter {
            $0[keyLinkAttribute]?.stringValue() == key
        }
        for link in links {
            representedNode.graph?.disconnect(link: link)
        }
    }

    /// Add a node to the dictionary under a name `name`.
    public func setKey(_ key: String, for node: Node) {
        removeKey(key)
        add(node: node, attributes: [keyLinkAttribute: .string(key)])
    }

}
