//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/10.
//

import Foundation

public typealias OID = Int
public typealias PropertyKey = String
public typealias PropertyValue = String

/// Representation of an object in a graph space.
///
open class Object {
    /// Memory that the object is associated with.
    ///
    var space: GraphMemory?

    /// Identifier of the object that is unique within the owning memory.
    /// The attribute is populated when the object is associated with a memory.
    /// When the object is disassociate from a memory, the identifier is set to
    /// `nil`.
    ///
    public internal(set) var id: OID?
    
    /// Create an empty object. The object needs to be associated with a memory.
    ///
    public init(id: OID?=nil) {
        self.id = id
    }
}
