//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/10.
//

// FIXME: This is only for Value. Decouple value from Record.
import Records

/// Type for graph object identifier. There should be no expectation about
/// the value of the identifier.
///
public typealias OID = Int

/// Type for object attribute key.
public typealias AttributeKey = String

/// Type for object attribute values.
public typealias AttributeValue = Value

/// Type for a dictionary of graph object attributes.
public typealias AttributeDictionary = [AttributeKey:AttributeValue]

/// An abstract class representing all objects in a graph. Concrete
/// kinds of graph objects are ``Node`` and ``Link``. Graph objects can store
/// information in form of attributes and their values.
///
/// All object's attributes are optional. It is up to the user to add
/// constraints or validations for the attributes of graph objects.
///
open class Object: Identifiable {
    /// Graph the object is associated with.
    ///
    public internal(set) var graph: Graph?
    
    
    /// A dictionary of object's attributes.
    ///
    public internal (set) var attributes: [AttributeKey:AttributeValue] = [:]
    
    /// List of all keys of object's attributes that are set to some value.
    ///
    var attributeKeys: [AttributeKey] {
        return Array(attributes.keys)
    }

    /// Identifier of the object that is unique within the owning graph.
    /// The attribute is populated when the object is associated with a graph.
    /// When the object is disassociate from a graph, the identifier is set to
    /// `nil`.
    ///
    public internal(set) var id: OID?
    
    /// Create an empty object. The object needs to be associated with a graph.
    ///
    public init(id: OID?=nil, attributes: [AttributeKey:AttributeValue]=[:]) {
        self.id = id
        self.attributes = attributes
    }

    
    public subscript(_ key:AttributeKey) -> AttributeValue? {
        /// Gets attribute value for an attribute key `key`. If the attribute
        /// is not set then it returns `nil`.
        get {
            return attributes[key]
        }
        /// Sets attribute value for an attribute key `key`.
        set(value) {
            attributes[key] = value

            // Notify graph
            guard let graph = self.graph else {
                return
            }

            if let value = value {
                graph.didChange(.setAttribute(self, key, value))
            }
            else {
                graph.didChange(.unsetAttribute(self, key))
            }
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
