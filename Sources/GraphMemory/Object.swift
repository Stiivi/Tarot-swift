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
open class Object: Identifiable {
    /// Graph memory that the object is associated with.
    ///
    public internal(set) var graph: GraphMemory?
    
    
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
    public init(id: OID?=nil, attributes: [String:Value]=[:]) {
        self.id = id
        self.attributes = attributes
    }

    public subscript(_ key:String) -> Value? {
        get {
            return attributes[key]
        }
        set(value) {
            // #FIXME: Notify memory delegate
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

extension Object: CustomStringConvertible {
    public var description: String {
        let items = attributes.map { "\($0.key): \($0.value)" }
        let joined = items.joined(separator: ", ")
        let idString = id.map { String($0) } ?? "nil"
        
        return "Object(id: \(idString), attributes: [\(joined)])"
    }
}


extension Object {
    /// Returns object represented as a dictionary. Keys are attribute keys and
    /// values are object's attribute values.
    ///
    /// This method can be used for extracting the object in a structured form,
    /// such as JSON. Or it can be used for debugging.
    ///
    /// Currently there is no inverse function that would convert a dictionary
    /// to an object.
    ///
//    public func asDictionary() -> [String:Any] {
//        let items = attributes.map {
//            let key = $0.key
//            let value: Any
//            
//            switch $0.value {
//            case .
//            }
//        }
//    }
}
