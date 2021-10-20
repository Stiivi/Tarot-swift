//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

import Foundation
import Foundation
import GraphMemory
import Records

/// Validate records in the record set whether the contents is convertible
/// to graph nodes.
///
/// - Parameters:
///     - records: Record set containing nodes
///     - idField: Name of a field containing node ID that is unique within the
///     record set
///
/// - Returns: List of issues found within the record set.
///
func validateNodeRecords(_ records: RecordSet, idField: String) -> [String] {
    guard records.schema.hasField(idField) else {
        return ["No field for node key `\(idField)`."]
    }

    var issues: [String] = []

    let summary = records.summary(of: idField)
    if summary.emptyCount > 0 {
        issues.append("Missing keys in \(summary.noneCount) records")
    }
    let dupeCount = summary.someCount - summary.uniqueCount
    if dupeCount > 0 {
        issues.append("Duplicate fields found. Count: \(dupeCount)")
    }
    // Check for duplicate keys
    
    let distinct = records.distinctCount(of: idField)
    
    for item in distinct {
        if item.value > 1 {
            issues.append("Duplicate key: \(item.key)")
        }
    }
    return issues
}

/// Validate records in the record set whether the contents is convertible
/// to graph links.
///
/// - Parameters:
///     - records: A record set to be valiedate
///     - originField: Name of a field containing link origin reference
///     - originField: Name of a field containing link target reference
///     - originField: Name of a field containing link name
///
/// - Returns: List of issues found within the record set.
///
func validateLinkRecords(_ records: RecordSet, nodeIDs: Set<Value>, originField: String="origin", targetField: String="target", nameField: String="name") -> [String] {
    var issues: [String] = []
    var hasSchemaIssues: Bool = false

    if !records.schema.hasField(originField) {
        hasSchemaIssues = true
        issues.append("No field for link origin `\(originField)`.")
    }
    if !records.schema.hasField(targetField) {
        hasSchemaIssues = true
        issues.append("No field for link target `\(targetField)`.")
    }
    if !records.schema.hasField(nameField) {
        hasSchemaIssues = true
        issues.append("No field for link name `\(nameField)`.")
    }
    
    guard !hasSchemaIssues else {
        return issues
    }

    // Now we can safely proceed to the record validation...
    //

    var summary = records.summary(of: originField)
    if summary.emptyCount > 0 {
        issues.append("Missing origins in \(summary.noneCount) link records")
    }

    summary = records.summary(of: targetField)
    if summary.emptyCount > 0 {
        issues.append("Missing targets in \(summary.noneCount) link records")
    }

    // Check for references
    //
    
    var diff: Set<Value> = []
    let origins = records.distinctValues(of: originField)
    diff = origins.subtracting(nodeIDs)
    if diff.count > 1 {
        issues.append("Unknown origin node references: \(diff)")
    }
    
    let targets = records.distinctValues(of: targetField)
    diff = targets.subtracting(nodeIDs)
    if diff.count > 1 {
        issues.append("Unknown target references: \(diff)")
    }
    
    return issues
}

