//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/10.
//

// FIXME: This is only for Value. Decouple value from Record.
import Records

public typealias OID = Int
public typealias AttributeKey = String
public typealias AttributeValue = Value

/// An abstract class representing all objects in a graph memory. Concrete
/// kinds of graph objects are ``Node`` and ``Link``. Graph objects can store
/// information in form of attributes and their values.
///
/// All object's attributes are optional. It is up to the user to add
/// constraints or validations for the attributes of graph objects.
///
open class Object: Identifiable {
    /// Graph memory that the object is associated with.
    ///
    public internal(set) var graph: GraphMemory?
    
    
    /// A dictionary of object's attributes.
    ///
    public internal (set) var attributes: [AttributeKey:AttributeValue] = [:]
    
    /// List of all keys of object's attributes that are set to some value.
    ///
    var attributeKeys: [AttributeKey] {
        return Array(attributes.keys)
    }

    /// Identifier of the object that is unique within the owning memory.
    /// The attribute is populated when the object is associated with a memory.
    /// When the object is disassociate from a memory, the identifier is set to
    /// `nil`.
    ///
    public internal(set) var id: OID?
    
    /// Create an empty object. The object needs to be associated with a memory.
    ///
    public init(id: OID?=nil, attributes: [AttributeKey:AttributeValue]=[:]) {
        self.id = id
        self.attributes = attributes
    }

    public subscript(_ key:AttributeKey) -> AttributeValue? {
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
