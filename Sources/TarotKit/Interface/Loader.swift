//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/6.
//

// FIXME: Rename this to TabularPackageLoader or RecordSetLoader
// FIXME: Consolidate error reporting mechanism
// FIXME: There are mutliple error reporting mechanisms: exception, issue list

import Foundation
import Records

/// Errors raised by the Importer
///
public enum LoaderError: Error {
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

/// Mapping of fields in an external source. Field map is used by the
/// ``Loader``.
///
public struct FieldMap {
    /// Name of a field which contains unique node identifier.
    public var nodeKeyField: String = "id"

    /// Name of a field in a link record which contains idendifier of an origin
    /// node.
    public var originField: String = "origin"

    /// Name of a field in a link record which contains idendifier of an target
    /// node.
    public var targetField: String = "target"
    
    public init(nodeKey: String="id", origin: String="origin", target: String="target") {
        self.nodeKeyField = nodeKey
        self.originField = origin
        self.targetField = target
    }
}

extension FieldMap: Decodable {
    enum CodingKeys: String, CodingKey {
        case nodeKey
        case origin
        case target
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let nodeKey = try container.decodeIfPresent(String.self, forKey: .nodeKey)
        let originField = try container.decodeIfPresent(String.self, forKey: .origin)
        let targetField = try container.decodeIfPresent(String.self, forKey: .target)

        if let key = nodeKey {
            self.nodeKeyField = key
        }
        if let key = originField {
            self.originField = key
        }
        if let key = targetField {
            self.targetField = key
        }
    }
}

/// Importer loads records from external source into the graph memory. One
/// instance of the importer represents one import session within one namespace.
///
public class Loader {
    /// Graph memory into which the nodes will be imported
    let memory: GraphMemory
    
    /// Naming conventions for this import session.
    var fieldMap: FieldMap
    
    /// Names
    /// are used for looking-up nodes by reference.
    typealias Namespace = [String:Node]
    var defaultNamespace: Namespace
    var namespaces: [String:Namespace]
    // var names: [String:Node]
    
    /// Creates an importer for a graph memory.
    ///
    /// - Parameters:
    ///
    ///     - space: Graph memory to import objects into.
    ///     - naming: Naming conventions for this import session.
    ///
    public init(memory: GraphMemory, fieldMap: FieldMap?=nil) {
        self.memory = memory
        self.fieldMap = fieldMap ?? FieldMap()
    
        namespaces = [:]
        defaultNamespace = [:]
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
    public func namedNode(_ name: String, namespace namespaceName: String?=nil) -> Node? {
        if let namespaceName = namespaceName {
            let namespace = namespaces[namespaceName]
            return namespace?[name]
        }
        else {
            return defaultNamespace[name]
        }
    }
    
    /// Sets name for a node.
    ///
    /// - Parameters:
    ///
    ///     - name: Name to be set for a node.
    ///     - node: Node to be referenced
    ///       Default is "default".
    ///
    public func setNodeName(_ name: String, node: Node,
                            namespace namespaceName: String?=nil) {
        if let namespaceName = namespaceName {
            if namespaces[namespaceName] == nil {
                namespaces[namespaceName] = [:]
            }
            namespaces[namespaceName]![name] = node
        }
        else {
            defaultNamespace[name] = node
        }
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
        guard records.schema.hasField(fieldMap.nodeKeyField) else {
            let issue = Issue(.error, "Missing node key field `\(fieldMap.nodeKeyField)`.")
            return [issue]
        }

        let issues = IssueList()
        
        // Validate value completeness
        //
        let summary = records.summary(of: fieldMap.nodeKeyField)
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
        let distinct = records.distinctCount(of: fieldMap.nodeKeyField)
        
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
    // FIXME: Replace trait with function to setup newly created node
    @discardableResult
    public func loadNodes(contentsOfCSVFile url: URL,
                          namespace: String?=nil,
                          trait: Trait?=nil,
                          options: CSVReadingOptions=CSVReadingOptions()) throws -> [String:Node] {
        guard let records = try RecordSet(contentsOfCSVFile: url,
                                          options: options) else {
            throw LoaderError.resourceLoadError(url)
        }
               
        let issues = validateNodeRecords(records)

        guard !issues.hasErrors else {
            throw LoaderError.validationError(issues)
        }
        
        return try loadNodes(records: records,
                             namespace: namespace,
                             trait: trait)
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
    public func loadNodes(records: RecordSet,
                          namespace: String?=nil,
                          trait: Trait?=nil) throws -> [String:Node] {
        // FIXME: Should return list of imported nodes or a dictionary.
        var imported: [String:Node] = [:]
        
        for record in records {
            let name = try importNode(record, namespace: namespace, trait: trait)
            imported[name] = namedNode(name, namespace: namespace)
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
                    namespace: String?=nil,
                    trait: Trait?=nil) throws -> String {
        guard let keyValue = record[fieldMap.nodeKeyField] else {
            throw LoaderError.missingField(fieldMap.nodeKeyField)
        }
        let nodeKey = keyValue.stringValue()

        let node = Node()
        node.trait = trait
        
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
        
        if namedNode(nodeKey, namespace: namespace) != nil {
            throw LoaderError.duplicateID
        }
        else {
            setNodeName(nodeKey, node:node, namespace: namespace)
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
    public func validateLinkRecords(_ records: RecordSet,
                                    namespace: String?=nil) -> IssueList {
        let issues = IssueList()

        var hasSchemaIssues: Bool = false

        if !records.schema.hasField(fieldMap.originField) {
            hasSchemaIssues = true
            issues.error("No field for link origin `\(fieldMap.originField)`.")
        }
        if !records.schema.hasField(fieldMap.targetField) {
            hasSchemaIssues = true
            issues.error("No field for link target `\(fieldMap.targetField)`.")
        }

        guard !hasSchemaIssues else {
            return issues
        }

        // Now we can safely proceed to the record validation...
        //

        var summary = records.summary(of: fieldMap.originField)
        if summary.emptyCount > 0 {
            issues.error("Missing origins in \(summary.noneCount) link records")
        }

        summary = records.summary(of: fieldMap.targetField)
        if summary.emptyCount > 0 {
            issues.error("Missing targets in \(summary.noneCount) link records")
        }

        // Check for references
        //
        let origins = records.distinctValues(of: fieldMap.originField)
        for originValue in origins {
            // FIXME: Test for stringValue != nil
            let origin = originValue.stringValue()
            if namedNode(origin, namespace: namespace) == nil {
                issues.error("Unknown origin node reference: \(origin)")
            }
        }
        let targets = records.distinctValues(of: fieldMap.originField)
        for targetValue in targets {
            let target = targetValue.stringValue()
            if namedNode(target, namespace: namespace) == nil {
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
    public func importLinksFromCSV(contentsOfCSVFile url: URL,
                                   namespace: String?=nil,
                                   options: CSVReadingOptions=CSVReadingOptions()) throws {
        guard let records = try RecordSet(contentsOfCSVFile: url, options:options) else {
            throw LoaderError.resourceLoadError(url)
        }
               
        let issues = validateLinkRecords(records, namespace: namespace)

        guard !issues.hasErrors else {
            throw LoaderError.validationError(issues)
        }
        
        try importLinks(records, namespace: namespace)
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
    public func importLinks(_ records: RecordSet, namespace: String?=nil) throws {

        for record in records {
            guard let originKeyValue = record[fieldMap.originField] else {
                throw LoaderError.missingField(fieldMap.originField)
            }

            guard let targetKeyValue = record[fieldMap.targetField] else {
                throw LoaderError.missingField(fieldMap.targetField)
            }

            let originKey = originKeyValue.stringValue()
            let targetKey = targetKeyValue.stringValue()

            guard let origin = namedNode(originKey, namespace: namespace) else {
                throw LoaderError.unknownNode(originKey)
            }
            guard let target = namedNode(targetKey, namespace: namespace) else {
                throw LoaderError.unknownNode(targetKey)
            }

            let link = memory.connect(from: origin, to: target)
            for field in record.schema.fieldNames {
                link[field] = record[field]
            }
        }
    }
    
    /// Loads a tabular package into the memory.
    ///
    /// See ``TabularPackage`` for more information.
    ///
    /// - Parameters:
    ///
    ///     - descriptionFile: Loaction of a file containing description
    ///       of the package
    ///     - dataRoot: optional path to a location where tabular data files
    ///       are stored if different from the package description
    ///
    // FIXME: Model does not belong here, it is from semantic layer
    public func load(package: Package, model: Model) throws {
        // Load the tabular package description
        
        // FIXME: Either this or the init version must go away
        if let fieldMap = package.fieldMap {
            self.fieldMap = fieldMap
        }
        
        for nodeDesc in package.nodes {
            print("Loading nodes from \(nodeDesc.resource)")
            let url = package.url(forResource: nodeDesc.resource)
            let trait: Trait?
            
            if let traitName = nodeDesc.trait {
                trait = model.trait(name: traitName)
            }
            else {
                trait = nil
            }

            try loadNodes(contentsOfCSVFile: url,
                          namespace: nodeDesc.namespace,
                          trait: trait,
                          options: package.resourceOptions ?? CSVReadingOptions())
        }
        for linkDesc in package.links {
            print("Loading links from \(linkDesc.resource)")
            let url = package.url(forResource: linkDesc.resource)

            try importLinksFromCSV(contentsOfCSVFile: url,
                          namespace: linkDesc.namespace,
                          options: package.resourceOptions ?? CSVReadingOptions())
        }
        
    }
}
