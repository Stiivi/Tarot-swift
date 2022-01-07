//
//  RecordSet.swift
//  

import Foundation

/// Collection of records with common schema.
///
///
// TODO: It is an immutable SetAlgebra type
public class RecordSet: Sequence {
    /// Schema of the record set.
    var _schema: Schema
    public var records: [Record]
    
    /// Create a new record set with given schema and records. The records are
    /// expectet to have the same schema. If the schemas are not matching then
    /// the initialization fails.
    ///
    public init(schema: Schema, _ records: [Record]=[]) {
        self._schema = schema
        self.records = records
    }
   
    /// Create a new record set with given schema and list of record values.
    ///
    public init(schema: Schema, _ rows: [[Value]]=[]) {
        self._schema = schema
        self.records = []
        
        for row in rows {
            let record = Record(schema: schema, row)
            records.append(record)
        }
    }
    
    // FIXME: This is quick hack
    public var schema: Schema {
        get {
            return self._schema
        }
        set(newSchema) {
            self._schema = newSchema
            for record in records {
                record.schema = newSchema
            }
        }
    }
    
    /// Create a new record set with contents of a CSV file. Schema of the
    /// record set will have fields with names from the header row and all
    /// value types will be `string`.
    ///
    /// Initializer fails if the CSV file does not have a header.
    public convenience init(contentsOfCSVFile url: URL,
                             options: CSVReadingOptions=CSVReadingOptions()) throws {
        let string = try String(contentsOf: url)
        
        self.init(csvString: string, options: options)
    }

    /// Create a new record set with contents of a CSV string. Schema of the
    /// record set will have fields with names from the header row and all
    /// value types will be `string`.
    ///
    /// Initializer fails if the CSV file does not have a header.
    public init(csvString string: String,
                options: CSVReadingOptions=CSVReadingOptions()) {
        let reader = CSVReader(string, options: options)

        if let header = reader.next() {
            _schema = Schema(header, type: .string)
        }
        else {
            _schema = Schema()
        }

        records = []

        for row in reader {
            let values:[Value] = row.map { .string($0) }
            let record = Record(schema: _schema, values)
            records.append(record)
        }
    }
    
    /// Creates a record iterator.
    ///
    public func makeIterator() -> Array<Record>.Iterator {
        return records.makeIterator()
    }
   
    /// Count of records in the record set.
    ///
    public var count: Int { records.count }
    /// Get all values for field `fieldName` as a list.
    ///
    /// - Returns: List of values.
    ///
    public func values(of fieldName: String) -> [Value?] {
        let result: [Value?]
        
        result = records.map {
            $0[fieldName]
        }
        
        return result
    }
    
    /// Get all distinct values for given field
    ///
    /// - Returns: A set of values.
    public func distinctValues(of fieldName: String) -> Set<Value> {
        return Set(values(of:fieldName).compactMap { $0 })
    }
    
    /// Counts values for a field with name `fieldName`.
    ///
    /// - Returns: Count of presence of a given field.
    ///
    public func valueCount(_ fieldName: String, value: Value) -> Int {
        let result: Int
        result = records.reduce(0) {acc,record in
            if let recordValue = record[fieldName] {
                if recordValue == value {
                    return acc + 1
                }
                return acc
            }
            else {
                return acc
            }
        }
        return result
    }
    
    /// Count values for given field and returns total count, count of non-nil
    /// values and count of unique values.
    ///
    /// - Returns: Summary of values.
    ///
    public func summary(of fieldName: String) -> ValueSummary {
        var summary: ValueSummary = ValueSummary()
        var seen: Set<Value> = Set()
        
        for record in records {
            if let value = record[fieldName] {
                seen.insert(value)
                summary.emptyCount += value.isEmpty ? 1 : 0
            }
            else {
                summary.noneCount += 1
                summary.emptyCount += 1
            }
        }
        summary.totalCount = records.count
        summary.someCount = summary.totalCount - summary.noneCount
        summary.uniqueCount = seen.count
        return summary
    }
    
    /// Count distinct values of given field
    ///
    /// - Returns: A dictionary where keys are field values and dictionary values are
    ///            counts of occurences of given field value.
    ///
    public func distinctCount(of fieldName: String) -> [Value:Int] {
        var counts: [Value:Int] = [:]
        
        for value in values(of: fieldName) {
            if let value = value {
                if counts[value] == nil {
                    counts[value] = 1
                }
                else {
                    counts[value]! += 1
                }
            }
        }
        
        return counts
    }
}

/// Summary of values.
///
public struct ValueSummary {
    /// Count of fields with no value or `nil`.
    public var noneCount: Int = 0
    /// Count of non-empty values.
    public var someCount: Int = 0
    /// Count of all values.
    public var totalCount: Int = 0
    /// Count of unique values.
    public var uniqueCount: Int = 0
    /// Count of empty values. String value is considered empty if the lenght of
    /// a string is zero, numeric value is considered empty if the value is
    /// equal to zero.
    public var emptyCount: Int = 0
}
