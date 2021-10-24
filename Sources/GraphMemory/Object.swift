//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/10.
//

// FIXME: This is only for Value. Decouple value from Record.
import Records
public typealias OID = Int
public typealias PropertyKey = String
public typealias PropertyValue = String

/// An object in a graph memory. There are two types of objects: links and
/// nodes.
///
open class Object {
    /// Graph memory that the object is associated with.
    ///
    var graph: GraphMemory?
    
    
    /// Object attributes
    var attributes: [String:Value] = [:]

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

    public subscript(_ key:String) -> Value? {
        get {
            return attributes[key]
        }
        set(value) {
            attributes[key] = value
        }
    }
}
