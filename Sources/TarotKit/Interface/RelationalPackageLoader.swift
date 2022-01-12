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

/// An object that loads a relational data source into a graph.
///
/// The source is set of relations – tables, datasets, sets or collections
/// of records. A relation might either represent a collection of nodes or a
/// collection of links. Links can calso be represented by references between
/// records.
///
/// The data is stored in a directory package. Relations are stored in CSV
/// files. See ``RelationalPackage`` for more information.
///
///
/// ## Nodes
///
/// The loader will create a node for each record in the relation. The fields
/// will be preserved as node attributes with the same name.
/// The relation is expected to have one field that represents unique identifier
///
/// of the record. It is the _primary key_ field. This field will be used
/// to reference the created nodes during link creation. The default primary key
/// for a relation is `id`.
///
/// Relation with nodes might look like this:
///
/// | id | title | text |
/// | -- | ----- | ---- |
/// | 1 | Introduction | Once upon a time ... |
/// | 2 | Journey | They walked a lot ... |
/// | 3 | Crossroads | They had to split ... |
///
/// It can be described as:
///
/// ```swift
/// let chaptersRelation = NodeRelation(name: "chapters")
/// ```
///
/// Here is another relation containing cards that uses a different primary key:
///
/// | name | type | level |
/// | Aggregation | Capability | 2 |
/// | Automation | Capability | 2 |
/// | Adaptability | Indicator | 4 |
/// | Metrics | Artefact | 1 |
/// | Scheduling | Capability | 2 |
/// | Loading | Capability | 1 |
/// | Storage | Storage | 1 |
/// | Wild growth | Process | 4 |
///
/// ```swift
/// let cardsRelation = NodeRelation(
///     name: "cards",
///     primaryKey: "name"
/// )
/// ```

/// ## Links
///
/// There are two ways how the links are represented in the relational data
/// source. One way is through key field references, that is a relation might
/// contain fields that represent _foreign keys_. _Foreign key_ points to a
/// record in another relation. Another way of representation of liks is through
/// a links relation that desribes the links in more detail. The major
/// difference is, that the links created through foreign keys do not have
/// additional attributes. Links contained in a relation can have additional
/// attributes.
///
/// ### Links Relation
///
///Relation with links might look like this:
///
/// | origin | type | target |
/// | ------ | ---- | ------ |
/// | Aggregation | amplifies | Metrics |
/// | Automation | requires | Scheduling |
/// | Loading | requires | Storage |
/// | Wild Growth | inhibits | Adaptability |
///
/// The above example has two fields that form a link: `origin` for the link
/// origin and `target` for the link target. The remaining field `type` will
/// become link attribute.
///
/// Description of this link relation would be:
///
/// ```swift
/// let relation = LinkRelation(
///     name: "links",
///     originRelation: "cards"
/// )
/// ```
///
/// The field names for link _origin_ and _target_ can be chosen at will, but
/// they need to be explicitly specified in the relation description. For
/// example if we have fields `from` and `to` that reference other entities then
/// we would specify them as follows:
///
/// ```swift
/// let relation = LinkRelation(
///     name: "connections",
///     originRelation: "things",
///     originKey: "from",
///     targetKey: "to"
/// )
/// ```
///
/// See also: ``LinkRelation``.
///
/// ### Foreign Keys
///
/// Links can be also specified using _foreign keys_. A _foreign key_ is a field
/// that contains a reference to another relation. For example in the above
/// relation containing cards we have a field named `type` which might point
/// to another relation containing detailed description of types. If we want
/// to create links in the graph from nodes representing cards to nodes
/// representing their respective types, we can specify the relation like this:
///
/// ```swift
/// let cardsRelation = NodeRelation(
///     name: "cards",
///     primaryKey: "name",
///     foreignKeys: [
///         "type": "types"
///     ]
/// )
/// ```
///
/// This assumes that we have a relation with types:
///
/// | name | description |
/// | Capability | Ability that a system can do |
/// | Indicator | Measurable state of a system |
/// | Artefact | A product created by or in a system |
/// | Storage | Place where entities are stored |
/// | Process | Activity of a system |
///
/// ```swift
/// let typesRelation = NodeRelation(
///     name: "types",
///     primaryKey: "name"
/// )
/// ```
///
/// The links created using foreign keys have no attributes.
///
/// See also: ``NodeRelation``.
///
///
/// # Future Plans
///
/// In the future this class might be abstracted and broken into smaller parts:
/// `RelationalLoader` - loader of any relational data, `RelationalDataProvider`
/// - an abstract class for providing relational data, either from a file or
/// from a database.
///
public class RelationalPackageLoader: Loader {
    let space: Space

    /// A nested dictionary of mapping of primary keys to nodes. The top level
    /// dictionary keys are relation names, values are dictionaries of keys. The
    /// nested dictionary keys are primary keys and values are nodes.
    ///
    var keyNodeMaps: [String:[Value:Node]] = [:]
    
    /// Description of a link that is created from a foreign key reference.
    struct ForeignKeyLinkDescription {
        /// Relation from which the link originates.
        let originRelation: String
        /// Primary key of a record in the origin relation.
        let originKey: Value
        /// Name of the field in the origin relation that contained the
        /// reference
        let originField: String
        /// Relation to which the link points to.
        let targetRelation: String
        /// Primary key of a record in the target relation.
        let targetKey: Value
    }
    
    /// List of descriptions for creating foreign key based links.
    ///
    var foreignKeyLinkDescriptions: [ForeignKeyLinkDescription] = []

    public required init(space: Space) {
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
        if keyNodeMaps[name] == nil {
            keyNodeMaps[name] = [:]
        }
        keyNodeMaps[name]![key] = node
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
        return keyNodeMaps[name]?[key]
    }

    /// Load graph contained in the package into the associated space.
    ///
    /// For more information see: `class:Package`
    ///
    public func load(from source: URL) throws -> Node? {
        // Load the package info from `info.json`
        //
        guard let package = RelationalPackage(url: source) else {
            fatalError("Unable to load package: \(source)")
        }
        
        // Load the data
        // ---------------------------------------------------------------

        return try load(package: package)
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
    /// - Throws: ``LoaderError``
    ///
    public func load(package: RelationalPackage) throws -> Node? {
        let options = package.readingOptions ?? CSVReadingOptions()
        
        // 1. Load all the nodes and register all the keys
        // ---------------------------------------------------------------
        
        for relation in package.nodeRelations {
            let url = package.url(forResource: relation.resource)
            
            let records = try RecordSet(contentsOfCSVFile: url,
                                        options: options)
            
            try loadNodes(records, relation: relation)
        }
        
        // 2. Load all the links
        // ---------------------------------------------------------------
        for relation in package.linkRelations {
            let url = package.url(forResource: relation.resource)
            
            let records = try RecordSet(contentsOfCSVFile: url,
                                        options: options)

            try loadLinks(records, relation: relation)
        }

        // 3. Create links for foreign references
        // ---------------------------------------------------------------
        
        for desc in foreignKeyLinkDescriptions {
            var attributes: AttributeDictionary = [:]
            
            // Set a link attribute to the name of the field in the originating
            // relation. For example if we have `card.status` pointing to
            // `statuses` and the link attribute is `label` then we set
            // a link attribute `label` to `status`.
            //
            if let linkAttribute = package.info.foreignKeyLinkAttribute {
                attributes[linkAttribute] = .string(desc.originField)
            } else {
                // TODO: Move this out to RelationalPackageInfo
                attributes["label"] = .string(desc.originField)
            }
            
            try createLink(originKey: desc.originKey,
                           originRelation: desc.originRelation,
                           targetKey: desc.targetKey,
                           targetRelation: desc.targetRelation,
                           attributes: attributes)
        }
        
        return nil
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
            throw LoaderError.missingPrimaryKey(relation.primaryKey, relation.name)
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

            // Register potential foreign key reference that will be resolved
            // later
            if let targetRelation = relation.foreignKeys[field] {
                let linkDescription = ForeignKeyLinkDescription(
                    originRelation: relation.name,
                    originKey: primaryKey,
                    originField: field,
                    targetRelation: targetRelation,
                    targetKey: value
                )
                foreignKeyLinkDescriptions.append(linkDescription)
            }

            // Store the value
            // TODO: Do some primitive value conversion here. Maybe use traits?
            node[field] = value
        }
        
        space.memory.add(node)
        return node
    }
    
    /// Import links from a record set.
    ///
    @discardableResult
    public func loadLinks(_ records: RecordSet, relation: LinkRelation) throws -> [Link] {
        var links: [Link] = []
        
        for record in records {
            let link = try loadLink(record, relation: relation)
            links.append(link)
        }
        
        return links
    }
    
    /// Creates a link from a record.
    ///
    /// - Parameters:
    ///   - record: Record from which the link will be created.
    ///   - relation: Relation description that contains the record.
    ///
    /// The record is expected to have two fields - one field for origin node
    /// reference and one field for target node reference. Default names of the
    /// fields are `origin` and `target` respectivelly. Which fields are used
    /// is described in the relation description `relation`.
    ///
    /// The rest of the record attributes are loaded as the link attributes. The
    /// origin and the target attributes are excluded.
    ///
    /// If the fields are missing then a ``LoaderError.missingField`` error is
    /// thrown. If referenced nodes are missing then ``LoaderError.unknownNode``
    /// is thrown.
    ///
    /// - Throws: ``LoaderError``
    ///
    @discardableResult
    public func loadLink(_ record: Record, relation: LinkRelation) throws -> Link {
        guard let originKey = record[relation.originKey] else {
            throw LoaderError.missingField(relation.originKey, relation.name)
        }

        guard let targetKey = record[relation.targetKey] else {
            throw LoaderError.missingField(relation.targetKey, relation.name)
        }
        guard let origin = node(forKey: originKey, relation: relation.originRelation) else {
            throw LoaderError.unknownNode(originKey, relation.originRelation)
        }
        guard let target = node(forKey: targetKey, relation: relation.targetRelation) else {
            throw LoaderError.unknownNode(targetKey, relation.targetRelation)
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
    
    /// Create a link from node represented by a record in `originRelation`
    /// to a node represented by a record in `targetRelation`. The `originKey`
    /// and the `targetKey` are primary keys in the origin relation amd in the
    /// target relation respectively.
    ///
    @discardableResult
    public func createLink(originKey: Value, originRelation: String,
                           targetKey: Value, targetRelation: String,
                           attributes: AttributeDictionary = [:]) throws -> Link {
        
        guard let origin = node(forKey: originKey, relation: originRelation) else {
            throw LoaderError.unknownNode(originKey, originRelation)
        }
        guard let target = node(forKey: targetKey, relation: targetRelation) else {
            throw LoaderError.unknownNode(targetKey, targetRelation)
        }
        let link = space.memory.connect(from: origin, to: target, attributes: attributes)
        return link
    }
    
}
