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

/// Type of a node or a link label.
///
public typealias Label = String

/// Type for set of labels.
///
public typealias LabelSet = Set<Label>

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
open class Object: Identifiable, CustomStringConvertible {
    /// Graph the object is associated with.
    ///
    public internal(set) var graph: Graph?
    
    
    /// A set of labels.
    ///
    public internal (set) var labels: LabelSet = []
    
    /// A dictionary of object's attributes.
    ///
    public internal (set) var attributes: [AttributeKey:AttributeValue] = [:]
    
    /// List of all keys of object's attributes that are set to some value.
    ///
    public var attributeKeys: [AttributeKey] {
        return Array(attributes.keys)
    }
    
    /// Identifier of the object that is unique within the owning graph.
    /// The attribute is populated when the object is associated with a graph.
    /// When the object is disassociate from a graph, the identifier is set to
    /// `nil`.
    ///
    public internal(set) var id: OID?
    

    // TODO: Make this private. Use Graph.create() and Graph.connect()
    /// Create an empty object. The object needs to be associated with a graph.
    ///
    init(id: OID?=nil, labels: LabelSet=[], attributes: [AttributeKey:AttributeValue]=[:]) {
        self.id = id
        self.labels = labels
        self.attributes = attributes
    }

    /// Returns `true` if the object contains the given label.
    ///
    public func contains(label: Label) -> Bool {
        return labels.contains(label)
    }
    
    /// Sets object label.
    public func set(label: Label) {
        labels.insert(label)
    }
    
    /// Unsets object label.
    public func unset(label: Label) {
        labels.remove(label)
    }
    
    public subscript(_ key:AttributeKey) -> AttributeValue? {
        /// Gets attribute value for an attribute key `key`. If the attribute
        /// is not set it returns `nil`.
        get {
            return attributes[key]
        }
        /// Sets attribute value for an attribute key `key`.
        set(value) {
            let change: GraphChange
            if let value = value {
                change = .setAttribute(self, key, value)
            }
            else {
                change = .unsetAttribute(self, key)
            }

            self.graph?.willChange(change)

            attributes[key] = value

            self.graph?.didChange(change)
        }
    }

    public var description: String {
        let items = attributes.map { "\($0.key): \($0.value)" }
        let joined = items.joined(separator: ", ")
        let idString = id.map { String($0) } ?? "nil"
        
        return "Object(id: \(idString), labels: \(labels.sorted()), attributes: [\(joined)])"
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
