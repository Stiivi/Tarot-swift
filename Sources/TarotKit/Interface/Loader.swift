//
//  Loader.swift
//  
//
//  Created by Stefan Urbanek on 07/01/2022.
//

import Foundation
import Records

// TODO: Status: Experimental
/// Protocol for objects that load graphs from a source into a graph memory.
///
public protocol Loader {
    /// Create a loader and associate it with a space.
    ///
    init(space: Space)
    
    /// Load graph from `source` into the associated space.
    ///
    func load(from source: URL) throws
}

/// Errors raised by the Importer
///
public enum LoaderError: Error, Equatable {
    /// Record is missing a primary key field. Value is relation name.
    case missingPrimaryKey(String, String)
    
    /// Record is missing a field. First value is a field name, second value is
    /// relation name.
    case missingField(String, String)
    
    /// A duplicate primary key has been found. First value is the key value and
    /// the second value is relation name.
    case duplicateKey(Value, String)
    
    /// A node with given key can not be find.
    case unknownNode(Value, String)
}
