//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/01/2022.
//

import Foundation
import Records

// TODO: Merge this with Record from Records

/// A record in an external store.
///
public class StoreRecord {
    /// String that represents the type of the record. Interpretation of the
    /// string is let to the store.
    ///
    // TODO: Rename to typeName
    public let type: String?

    /// Record identifier
    // TODO: Make it an alias
    public let id: String
    
    /// Dictionary of record values.
    ///
    var dict: [String:Value]
    
    /// List of all keys in the record.
    ///
    var keys: [String]  { return Array(dict.keys) }
    
    /// Creates a record of type `type` with values from a dictionary `values`.
    ///
    init(type: String?=nil, id: String, values: [String:Value]?=nil) {
        self.type = type
        self.id = id
        self.dict = values ?? [:]
    }
    
    /// Subscript for getting and setting values for a key.
    ///
    public subscript(key: String) -> Value? {
        get {
            return dict[key]
        }
        set(value) {
            dict[key] = value
        }
    }
}
