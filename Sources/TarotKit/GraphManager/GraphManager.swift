//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/5.
//


/*

 STATUS: Experimental
 ISSUES:
 
 - weirdly coupled functionality

 NOTES:
 
 - application facing object, something like a controller
 - maybe should be called GraphController or GraphManager?
 
 - collections
    - custom created collections of nodes of assorted type
 - perspectives
    - custom collections of main nodes put into context of supportive nodes
 - views/projections/filters
    - 
 
 
 */

import Foundation
import Records

// TODO: Add semantics to connections, such as "name"
// TODO: Add removal of multiple nodes

/// GraphManager is an object that provides working context to the graph.
/// It also manages special nodes in the graph such as Catalog.
///
/// ## Catalog
///
/// Catalog is a special node that allows looking up nodes by their names.
///
/// To set names for objects in the catalog:
///
/// ```swift
/// let manager: GraphManager
/// let chapter: Node
///
/// manager.catalog["Chapter 1"] = chapter
/// ```
///
/// To retrieve a named object from the catalog:
///
/// ```swift
/// let manager: GraphManager
/// let chapter = manager.catalog["Chapter 1"]
///
/// ```
///
///
/// ## Persistence
///
/// Graph can be persisted into a store and later loaded from the store. For
/// example to initialize a graph from a file store:
///
/// ```swift
/// let dataURL = URL(fileURLWithPath: "Cards.tarot", isDirectory: true)
/// let store = try FilePackageStore(url: dataURL)
/// let manager = try GraphManager(store: store)
/// ```
///
/// Later we can persist the graph into the store:
///
/// ```swift
/// try manager.save(to: store)
///```
///
/// For further reading about stores read <doc:Persistence>
///
public class GraphManager {
    /// Graph that the manager manages.
    ///
    public let graph: Graph
    
    /// Node that represents the graph's catalog - mapping of names to objects.
    /// Typically catalog items are collections.
    ///
    /// Catalog is a collection node.
    ///
    public var catalog: KeyedCollection? = nil
    
    /// Create a manager with an empty graph.
    ///
    public init() {
        graph = Graph()
    }
    
    // Store reading and writing.
    //
    // TODO: Consider those two to be reference values that might be checked by the store
    /// Key for link origin in the record stored in the persistent store.
    /// It is intentionally longer to not to conflic with potential user keys.
    static let originRecordKey = "__link_origin"
    /// Key for link target in the record stored in the persistent store.
    /// It is intentionally longer to not to conflic with potential user keys.
    static let targetRecordKey = "__link_target"

    /// Write the whole graph and associated structures in a store.
    public func save(to store: PersistentStore) throws {
        // TODO: This is prone to corruption
        try store.deleteAll()
        
        // Write nodes
        // ---------------------------------------------------------------
        for node in graph.nodes {
            let id = String(node.id!)
            let record = StoreRecord(type: "node",  id: id, values: node.attributes)
            try store.save(record: record)
        }
        
        // Write links
        // ---------------------------------------------------------------
        for link in graph.links {
            let id = String(link.id!)
            let record = StoreRecord(type: "link", id: id, values: link.attributes)

            record[GraphManager.originRecordKey] = .int(link.origin.id!)
            record[GraphManager.targetRecordKey] = .int(link.target.id!)
            try store.save(record: record)
        }
        
        // Write catalog reference if it exists
        // ---------------------------------------------------------------
        if let catalog = self.catalog {
            let record = StoreRecord(type: "reference", id: "catalog")
            record["node"] = .int(catalog.representedNode.id!)
            try store.save(record: record)
        }

    }
    
    public func save(writer: GraphWriter) throws {
        var names: [String:Node] = [:]

        if let catalogNode = catalog?.representedNode {
            names["catalog"] = catalogNode
        }

        try writer.write(graph: graph, names: names)
    }

    /// Creates a graph from a Tarot file.
    ///
    /// See ``TarotFileLoader`` for information about the loading process
    /// and ``TarotFileWriter`` for information about the file format.
    ///
    public init(contentsOf url: URL) throws {
        graph = Graph()
        let loader = TarotFileLoader(graph: graph)
        let names = try loader.load(from: url, preserveIdentity: true)
        
        if let node = names["catalog"] {
            setCatalog(node)
        }
        else {
            print("WARNING: No catalog found.")
            catalog = nil
        }
    }
    
    // TODO: Deprecated
    /// Read the graph from a store.
    ///
    public init(store: PersistentStore) throws {
        // FIXME: Model is not preserved here

        graph = Graph()
        // Read nodes
        // ---------------------------------------------------------------
        // TODO: Document that we are using __id here
        for record in try store.fetchAll(type: "node") {
            let id = OID(record.id)
            
            var attributes: [String:Value] = [:]
            for key in record.keys {
                attributes[key] = record[key]
            }
            
            let node = Node(id: id, attributes: attributes)
            graph.add(node)
        }
        
        // Read links
        // ---------------------------------------------------------------
        for record in try store.fetchAll(type: "link") {
            let id = OID(record.id)

            // FIXME: Handle errors here instead of forcing unwrap
            let originID = OID(record[Self.originRecordKey]!.intValue()!)
            let targetID = OID(record[Self.targetRecordKey]!.intValue()!)

            let origin = graph.node(originID)!
            let target = graph.node(targetID)!
            
            var attributes: [String:Value] = [:]
            for key in record.keys {
                if key != Self.originRecordKey && key != Self.targetRecordKey {
                    attributes[key] = record[key]
                }
            }
            
            graph.connect(from: origin, to: target, attributes: attributes, id: id)
        }
    
        // FIXME: Handle errors here
        if let record = try store.fetch(id: "catalog") {
            let catalogNodeID = OID(record["node"]!.intValue()!)
            let node = graph.node(catalogNodeID)!
            setCatalog(node)
        }
        else {
            print("WARNING: No catalog found in the store.")
            catalog = nil
        }
    }
    
    /// Sets a new catalog node.
    public func setCatalog(_ node: Node) {
        guard node.graph === graph else {
            fatalError("Trying to set a catalog with a node from a different graph")
        }
        catalog = KeyedCollection(node, selector: LinkSelector("item"))
    }
    
}
