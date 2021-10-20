//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/6.
//

// FIXME: Consolidate error reporting mechanism
// FIXME: There are mutliple error reporting mechanisms: exception, issue list

import Records

enum ImporterError: Error {
    case missingID
    case typeError
    case duplicateID
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

/// Importer loads records from external source into the graph space.
///
public class Importer {
    typealias NodeNamespace = Namespace<String,Node>
    
    let space: GraphMemory
    let naming: ImporterNaming
    var namespaces: [String: NodeNamespace] = [:]
    
    public init(space: GraphMemory, naming: ImporterNaming?=nil) {
        self.space = space
        self.naming = naming ?? ImporterNaming()
    }
    
    func getNamespace(_ namespace: String) -> NodeNamespace{
        if let ns = namespaces[namespace] {
            return ns
        }
        else {
            let ns = NodeNamespace()
            namespaces[namespace] = ns
            return ns
        }
    }
    func namedNode(_ name: String, namespace: String="default") -> Node? {
        let ns = getNamespace(namespace)
        
        return ns[name]
    }
    
    func setNodeName(_ name: String, node: Node, namespace: String="default") {
        let ns = getNamespace(namespace)
        ns[name] = node
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
    public func validateNodeRecords(_ records: RecordSet, type: RecordRepresentable.Type) -> IssueList {
        guard records.schema.hasField(naming.nodeKeyField) else {
            let issue = Issue(.error, "No field for node key `\(naming.nodeKeyField)`.")
            return [issue]
        }

        var issues = IssueList()
        
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
        
        // Validate required schema
        //
        let diff = records.schema.difference(with: type.recordSchema)

        if diff.missingFields.count > 0 {
            issues.error("Records are missing fields: \(diff.missingFields)")
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
    public func validateLinkRecords(_ records: RecordSet, namespace: String="default") -> IssueList {
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
            let origin = originValue.stringValue()!
            if namedNode(origin, namespace: namespace) == nil {
                issues.error("Unknown origin node reference: \(origin)")
            }
        }
        let targets = records.distinctValues(of: naming.originField)
        for targetValue in targets {
            let target = targetValue.stringValue()!
            if namedNode(target, namespace: namespace) == nil {
                issues.error("Unknown target node reference: \(target)")
            }
        }

        return issues
    }

    /// Import nodes from a record set. Fails to import nodes if there are
    /// duplicates.
    ///
    public func importNodes(_ recordSet: RecordSet, namespace: String="default", type: RecordRepresentable.Type) -> IssueList {
        // FIXME: Should return list of imported nodes or a dictionary.
        
        var issues = IssueList()
        
        // Check for duplicates
        //
        // 1. Validate record set
        issues += validateNodeRecords(recordSet, type: type)

        for record in recordSet {
            do {
                // FIXME: Type mismatch, we need to make Node RecordRepresentable
                // TODO: Collect the nodes and return them
                try importNode(record, namespace: namespace, type: type)
            }
            catch {
                issues.error("Unable to create node from record: \(error) (\(record))")
                continue
            }
        }
     
        return issues
    }
    
    func importNode(_ record: Record, namespace: String="default", type: RecordRepresentable.Type) throws -> Node {
        guard let keyValue = record[naming.nodeKeyField] else {
            throw ImporterError.missingID
        }
        guard let nodeKey = keyValue.stringValue() else {
            throw ImporterError.typeError
        }

        let node = try type.init(record: record) as! Node

        space.associate(node)
        
        if namedNode(nodeKey) != nil {
            throw ImporterError.duplicateID
        }
        else {
            setNodeName(nodeKey, node:node, namespace:namespace)
        }

        return node
    }
}
