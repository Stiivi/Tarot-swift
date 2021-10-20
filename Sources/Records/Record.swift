//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/7.
//

import Foundation


/// Errors raised when working with records using strict functions.
///
public enum RecordError: Error, Equatable {
    /// Record does not have a field with given name.
    case fieldNotFound(String)
    /// Value of a field is of a different type than the requested type.
    case typeMismatch(String, ValueType)
    /// Value of a field is not present when it was expected to be present.
    case valueNotFound(String)
}

// TODO: Add RecordType

/// Record is a mutable data structure for storing values for up-front known
/// fields. Its intended use is for interfaces with external sources.
///
/// Record creation is forgiving for errors.
///
public class Record {
    public var schema: Schema
    var dict: [Schema.FieldKey:Value] = [:]
    
    /// Creates an empty record with given fields and optionally values.
    public init(schema:Schema, _ values: [Value?]?=nil) {
        self.schema = schema

        if let values = values {
            for (field, value) in zip(schema.fieldKeys, values) {
                dict[field] = value
            }
        }
    }
    
    /// Creates an empty record with given keys and values. The keys in the
    /// provided dictionary will shape the record.
    /// 
    public init(schema: Schema, _ dict: [String:Value?]) {
        var merged: [Schema.FieldKey:Value] = [:]

        for item in dict {
            guard let key = schema.firstFieldKey(name: item.key) else {
                continue
            }
            merged[key] = item.value
        }

        self.schema = schema
        self.dict = merged
    }
   
    /// Forgiving subscript that returs value of a field if the field with given
    /// name exists, otherwise returns `nil`.
    public subscript(fieldName: String) -> Value? {
        get {
            guard let key = schema.firstFieldKey(name: fieldName) else {
                return nil
            }
            return dict[key]
        }
        set(value) {
            guard let key = schema.firstFieldKey(name: fieldName) else {
                return
            }
            dict[key] = value
        }
    }
    
    public func value(of fieldName: String) throws -> Value? {
        guard schema.contains(fieldName) else {
            throw RecordError.fieldNotFound(fieldName)
        }
        return self[fieldName]
    }
    // For RecordRepresentable
    public func stringValue(of fieldName: String) throws -> String? {
        let value = try value(of: fieldName)
        return value?.stringValue()
    }
    // For RecordRepresentable
    public func intValue(of fieldName: String) throws -> Int? {
        let value = try value(of: fieldName)
        return value?.intValue()
    }
    // For RecordRepresentable
    public func boolValue(of fieldName: String) throws -> Bool? {
        let value = try value(of: fieldName)
        return value?.boolValue()
    }
    // For RecordRepresentable
    public func doubleValue(of fieldName: String) throws -> Double? {
        let value = try value(of: fieldName)
        return value?.doubleValue()
    }
}



/// A protocol for objects that can be represented by a record. Objects that are
/// representable by a record can be initialized from a record and can be
/// converted to a record.
///
/// Typical use-case for this protocol is conversion between external sources
/// and application objects.
///
/// Note: Objects represented by records are non-recursive structures since
/// there is no explicit way how to represent and handle references in records.
///
public protocol RecordRepresentable {
    /// Create object instance from a record.
    ///
    init(record: Record) throws
    
    /// Creates a record that fully represents the object.
    ///
    func recordRepresentation() -> Record
    
    /// Minimal schema that is required when creating objects from records.
    /// The records the obeject is being created from might contain additional
    /// fields although only fields described in this schema are required.
    /// Validators can use this method to validate records prior to creation to
    /// prevent errors.
    static var recordSchema: Schema { get }
}

extension RecordRepresentable {
    /// Default implementation provides and empty schema as required schema.
    static var recordSchema: Schema { Schema() }
}

