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

/// An object in a graph memory. It represents one of two graph components:
/// a node or a link. Objects can store information
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

extension Object: Hashable {
    // TODO: Equality is based on identity withing graph
    public static func == (lhs: Object, rhs: Object) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Object: CustomDebugStringConvertible {
    public var debugDescription: String {
        var items = attributes.map { "\($0.key): \($0.value)" }
        var joined = items.joined(separator: ", ")
        
        return "Object{\(joined)}"
    }
}
