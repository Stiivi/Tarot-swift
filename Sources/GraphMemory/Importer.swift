//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/6.
//

// FIXME: Consolidate error reporting mechanism
// FIXME: There are mutliple error reporting mechanisms: exception, issue list

import Foundation
import Records

/// Errors raised by the Importer
///
public enum ImportError: Error {
    /// The validation of records that were attempted to be imported failed.
    /// The associated list contains list of issues identified.
    case validationError(IssueList)
    /// Loading of a resource failed.
    case resourceLoadError(URL)
    /// Creating an instance from record failed
    case instantionFailed(Record)
    case missingField(String)
    case typeError(String)
    case duplicateID
    /// Node not found by name
    case unknownNode(String)
}

public struct ImporterNaming {
    /// Name of a field which contains unique node identifier.
    public var nodeKeyField: String = "id"

    /// Name of a field in a link record which contains idendifier of an origin
    /// node.
    public var originField: String = "origin"

    /// Name of a field in a link record which contains idendifier of an target
    /// node.
    public var targetField: String = "target"

    /// Name of a field in a link record which contains link name.
    public var linkNameField: String = "name"

    public init() {
    }
}

/// Importer loads records from external source into the graph memory. One
/// instance of the importer represents one import session within one namespace.
///
public class Importer {
    /// Graph memory into which the nodes will be imported
    let memory: GraphMemory
    
    /// Naming conventions for this import session.
    let naming: ImporterNaming
    
    /// Names
    /// are used for looking-up nodes by reference.
    var names: [String:Node]
    
    /// Creates an importer for a graph memory.
    ///
    /// - Parameters:
    ///
    ///     - space: Graph memory to import objects into.
    ///     - naming: Naming conventions for this import session.
    ///
    public init(memory: GraphMemory, naming: ImporterNaming?=nil, references: [String:Node]?=nil) {
        self.memory = memory
        self.naming = naming ?? ImporterNaming()
    
        if let references = references {
            names = references
        }
        else {
            names = [:]
        }
    }
    
    /// Get a node by name
    ///
    /// - Parameters:
    ///
    ///     - name: Node name to be looked up.
    ///
    /// - Returns: Node if the node was found or `nil` if the node was not
    ///   found.
    ///
    public func namedNode(_ name: String) -> Node? {
        return names[name]
    }
    
    /// Sets name for a node.
    ///
    /// - Parameters:
    ///
    ///     - name: Name to be set for a node.
    ///     - node: Node to be referenced
    ///       Default is "default".
    ///
    public func setNodeName(_ name: String, node: Node) {
        names[name] = node
    }

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
    public func validateNodeRecords(_ records: RecordSet) -> IssueList {
        guard records.schema.hasField(naming.nodeKeyField) else {
            let issue = Issue(.error, "Missing node key field `\(naming.nodeKeyField)`.")
            return [issue]
        }

        let issues = IssueList()
        
        // Validate value completeness
        //
        let summary = records.summary(of: naming.nodeKeyField)
        if summary.emptyCount > 0 {
            issues.error("Missing keys in \(summary.noneCount) records")
        }
        
        // Validate uniqueness of keys
        //
        let dupeCount = summary.someCount - summary.uniqueCount
        if dupeCount > 0 {
            issues.error("Duplicate fields found. Count: \(dupeCount)")
        }

        // Check for concrete duplicate keys
        //
        let distinct = records.distinctCount(of: naming.nodeKeyField)
        
        for item in distinct {
            if item.value > 1 {
                issues.error("Duplicate key: \(item.key)")
            }
        }
        
        return issues
    }

    /// Validates and imports nodes from a CSV file located at given URL.
    ///
    /// - Parameters:
    ///
    ///     - url: URL of the CSV file
    ///     - trait: Model node trait that is used for adjusting types of the node
    ///       properties
    ///     - fieldMap: a dictionary to map CSV field names into record
    ///       field names. Keys are CSV field names, values are record field
    ///       names
    ///
    /// - Returns: Dictionary of imported nodes where keys are node names and
    ///            values are imported nodes.
    ///
    /// - Throws: ``ImportError``
    ///
    @discardableResult
    public func importNodesFromCSV(_ url: URL,
                                   trait: Trait?=nil,
                                   fieldMap: [String:String]=[:]) throws -> [String:Node] {
        guard let records = try RecordSet(contentsOfCSVFile: url) else {
            throw ImportError.resourceLoadError(url)
        }
               
        if fieldMap.count > 0 {
            records.schema = records.schema.renamed(fieldMap)
        }
        
        let issues = validateNodeRecords(records)

        guard !issues.hasErrors else {
            throw ImportError.validationError(issues)
        }
        
        return try importNodes(records, trait: trait)
    }

    /// Import nodes from a record set. The `records` are expeced to be
    /// validated by ``validateNodeRecords(_:type:)``
    ///
    /// - Parameters:
    ///
    ///     - records: a `RecordSet` of records that represent nodes to be
    ///       imported
    ///     - type: subclass of Node that will be used to instantiate the
    ///       records
    ///
    /// - Returns: Dictionary of imported nodes where keys are node names and
    ///            values are imported nodes.
    /// - Throws: ``ImportError``
    ///
    @discardableResult
    public func importNodes(_ records: RecordSet,
                            trait: Trait?=nil) throws -> [String:Node] {
        // FIXME: Should return list of imported nodes or a dictionary.
        var imported: [String:Node] = [:]
        
        for record in records {
            let name = try importNode(record, trait: trait)
            imported[name] = names[name]!
        }
     
        return imported
    }
    
    /// Imports a record as a node. An instance of Node or Node's subclass is
    /// created from the record's fields and is associated with the graph.
    ///
    /// - Parameters:
    ///
    ///     - records: a `RecordSet` of records that represent nodes to be
    ///       imported
    ///     - type: subclass of Node that will be used to instantiate the
    ///       records
    ///     - action: Optional action to be exectued when the node is
    ///       successfully imported. Argument to the block is `(name, node)`
    ///
    /// - Returns: Name of the imported note that was registered.
    /// - Throws: ``ImportError``
    ///
    @discardableResult
    func importNode(_ record: Record,
                    trait: Trait?=nil) throws -> String {
        guard let keyValue = record[naming.nodeKeyField] else {
            throw ImportError.missingField(naming.nodeKeyField)
        }
        guard let nodeKey = keyValue.stringValue() else {
            throw ImportError.typeError(naming.nodeKeyField)
        }

        let node = Node()
        
        for field in record.schema.fieldNames {
            // TODO: Do we need to preserve nils?
            guard let value = record[field] else {
                continue
            }
            
            if let trait = trait, let property = trait.property(name: field) {
                node[field] = value.convert(to:property.valueType)
            }
            else {
                node[field] = value
            }
        }

        memory.add(node)
        
        if namedNode(nodeKey) != nil {
            throw ImportError.duplicateID
        }
        else {
            setNodeName(nodeKey, node:node)
        }
        
        return nodeKey
    }
    
    /// Validate records in the record set whether the contents is convertible
    /// to graph links.
    ///
    /// - Parameters:
    ///     - records: A record set to be validated
    ///
    /// - Returns: List of issues found within the record set.
    ///
    public func validateLinkRecords(_ records: RecordSet) -> IssueList {
        let issues = IssueList()

        var hasSchemaIssues: Bool = false

        if !records.schema.hasField(naming.originField) {
            hasSchemaIssues = true
            issues.error("No field for link origin `\(naming.originField)`.")
        }
        if !records.schema.hasField(naming.targetField) {
            hasSchemaIssues = true
            issues.error("No field for link target `\(naming.targetField)`.")
        }
        if !records.schema.hasField(naming.linkNameField) {
            hasSchemaIssues = true
            issues.error("No field for link name `\(naming.linkNameField)`.")
        }
        
        guard !hasSchemaIssues else {
            return issues
        }

        // Now we can safely proceed to the record validation...
        //

        var summary = records.summary(of: naming.originField)
        if summary.emptyCount > 0 {
            issues.error("Missing origins in \(summary.noneCount) link records")
        }

        summary = records.summary(of: naming.targetField)
        if summary.emptyCount > 0 {
            issues.error("Missing targets in \(summary.noneCount) link records")
        }

        // Check for references
        //
        let origins = records.distinctValues(of: naming.originField)
        for originValue in origins {
            // FIXME: Test for stringValue != nil
            let origin = originValue.stringValue()!
            if namedNode(origin) == nil {
                issues.error("Unknown origin node reference: \(origin)")
            }
        }
        let targets = records.distinctValues(of: naming.originField)
        for targetValue in targets {
            let target = targetValue.stringValue()!
            if namedNode(target) == nil {
                issues.error("Unknown target node reference: \(target)")
            }
        }

        return issues
    }

    /// Validates and imports links from a CSV file located at given URL.
    ///
    /// - Parameters:
    ///     - url: URL of the CSV file
    ///
    /// - Throws: ``ImportError``
    ///
    public func importLinksFromCSV(_ url: URL, namespace: String = "default") throws {
        guard let records = try RecordSet(contentsOfCSVFile: url) else {
            throw ImportError.resourceLoadError(url)
        }
               
        let issues = validateLinkRecords(records)

        guard !issues.hasErrors else {
            throw ImportError.validationError(issues)
        }
        
        try importLinks(records)
    }


    /// Import links from a record set. The record set is expected to have at
    /// least three fields: origin, target and name, where the `origin`
    /// and `target` are named references to nodes within registered names. The
    /// `name` field is the link name.
    ///
    /// - Parameters:
    ///     - records: Record set with links
    ///
    /// - Throws: ``ImportError``
    ///
    public func importLinks(_ records: RecordSet) throws {

        for record in records {
            guard let originKeyValue = record[naming.originField] else {
                throw ImportError.missingField(naming.originField)
            }
            guard let originKey = originKeyValue.stringValue() else {
                throw ImportError.typeError(naming.originField)
            }
            guard let targetKeyValue = record[naming.targetField] else {
                throw ImportError.missingField(naming.targetField)
            }
            guard let targetKey = targetKeyValue.stringValue() else {
                throw ImportError.typeError(naming.targetField)
            }
            guard let nameValue = record[naming.linkNameField] else {
                throw ImportError.missingField(naming.linkNameField)
            }
            guard let name = nameValue.stringValue() else {
                throw ImportError.typeError(naming.linkNameField)
            }

            guard let origin = namedNode(originKey) else {
                throw ImportError.unknownNode(originKey)
            }
            guard let target = namedNode(targetKey) else {
                throw ImportError.unknownNode(targetKey)
            }

            let link = memory.connect(from: origin, to: target, at: name)
            
            for field in record.schema.fieldNames {
                link[field] = record[field]
            }

        }
    }
}
