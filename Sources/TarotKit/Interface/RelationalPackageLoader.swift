//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 07/01/2022.
//

import Foundation
import Records

// TODO: Assign traits for nodes
// FIXME: Handle errors

public class RelationalPackageLoader {
    let space: Space

    /// A nested dictionary of mapping of primary keys to nodes. The top level
    /// dictionary keys are relation names, values are dictionaries of keys. The
    /// nested dictionary keys are primary keys and values are nodes.
    ///
    var keyNodeMap: [String:[Value:Node]] = [:]

    init(space: Space) {
        self.space = space
    }
    
    /// Registers a key for a node within a relation. If a key already exists
    /// it will be overwritten by the new node.
    ///
    /// - Parameters:
    ///   - key: Key under which the node will be registered
    ///   - forNode: Node to be registered
    ///   - relation: Name of a relation in which the `key` is a primary key
    ///
    public func setKey(_ key: Value, for node: Node, relation name: String) {
        if keyNodeMap[name] == nil {
            keyNodeMap[name] = [:]
        }
        keyNodeMap[name]![key] = node
    }
    
    /// Get a node by key.
    ///
    /// - Parameters:
    ///
    ///     - key: Node key to be looked up.
    ///     - relation: Name of a relation the key is a primary key of.
    ///
    /// - Returns: Node if the node was found or `nil` if the node was not
    ///   found.
    ///
    public func node(forKey key: Value, relation name: String) -> Node? {
        return keyNodeMap[name]?[key]
    }

    /// Loads a relational package into the space.
    ///
    ///
    /// ## Loading Process
    ///
    /// The loading process first loads all the nodes from node resources into
    /// the graph. While loading the nodes it builds a key reference index that
    /// will be used for creating links.
    ///
    /// Secondly it loads all the links from the link resources. It uses the
    /// key reference index to lookup nodes that are to be connected.
    ///
    /// Lastly it creates links for foreign references.
    ///
    public func load(package: RelationalPackage) throws {
        let options = package.readingOptions ?? CSVReadingOptions()
        
        // 1. Load all the nodes and register all the keys
        // ---------------------------------------------------------------
        
        for relation in package.nodeRelations {
            let url = package.url(forResource: relation.name)
            
            let records = try RecordSet(contentsOfCSVFile: url,
                                        options: options)
            
            try loadNodes(records, relation: relation)
        }
        
        // 2. Load all the links
        // ---------------------------------------------------------------
        for relation in package.linkRelations {
            let url = package.url(forResource: relation.name)
            
            let records = try RecordSet(contentsOfCSVFile: url,
                                        options: options)

            try loadLinks(records, relation: relation)
        }

        // 3. Create links for foreign references
        // ---------------------------------------------------------------
    }
    
    /// Loads nodes from a record set.
    ///
    /// - Parameters:
    ///
    ///     - records: a `RecordSet` of records that represent nodes to be
    ///       imported
    ///     - relation: description of a relation containing the nodes
    ///
    /// - Returns: List of imported nodes.
    /// - Throws: ``LoaderError``
    ///
    @discardableResult
    public func loadNodes(_ records: RecordSet, relation: NodeRelation) throws -> [Node]{
        var imported: [Node] = []
        
        for record in records {
            let node = try loadNode(record, relation: relation)
            imported.append(node)
        }
        return imported
    }
    
    /// Loads a record representing a node into the graph. The record structure
    /// is described by `relation`.
    ///
    /// - Parameters:
    ///   - record: Record that is to be used to create a new node.
    ///   - relation: Description of the record properties.
    ///
    /// - Throws: ``LoaderError``
    ///
    @discardableResult
    public func loadNode(_ record: Record, relation: NodeRelation) throws -> Node {
        guard let primaryKey = record[relation.primaryKey] else {
            throw LoaderError.missingPrimaryKey(relation.name)
        }
        guard node(forKey: primaryKey, relation: relation.name) == nil else {
            throw LoaderError.duplicateKey(primaryKey, relation.name)
        }
        // Create the node
        let node = Node()
        
        // Register the node key
        setKey(primaryKey, for: node, relation: relation.name)
        
        for field in record.schema.fieldNames {
            guard let value = record[field] else {
                continue
            }
            // TODO: Do some primitive value conversion here. Maybe use traits?
            node[field] = value
        }
        
        space.memory.add(node)
        return node
    }
    
    /// Import links from a record set.
    ///
    public func loadLinks(_ records: RecordSet, relation: LinkRelation) throws -> [Link] {
        var links: [Link] = []
        
        for record in records {
            let link = try loadLink(record, relation: relation)
            links.append(link)
        }
        
        return links
    }
    
    public func loadLink(_ record: Record, relation: LinkRelation) throws -> Link {
        guard let originKey = record[relation.originKey] else {
            throw LoaderError._missingField(relation.originKey, relation.name)
        }

        guard let targetKey = record[relation.targetKey] else {
            throw LoaderError._missingField(relation.targetKey, relation.name)
        }
        guard let origin = node(forKey: originKey, relation: relation.originRelation) else {
            throw LoaderError._unknownNode(originKey, relation.originRelation)
        }
        guard let target = node(forKey: targetKey, relation: relation.targetRelation) else {
            throw LoaderError._unknownNode(targetKey, relation.targetRelation)
        }
        
        var attributes: AttributeDictionary = [:]
        
        for field in record.schema.fieldNames {
            guard field != relation.originKey && field != relation.targetKey else {
                // Skip the origin and target fields that are used for the
                // connection
                continue
            }
            attributes[field] = record[field]
        }
        
        let link = space.memory.connect(from: origin, to: target, attributes: attributes)
        return link
    }
    
}
