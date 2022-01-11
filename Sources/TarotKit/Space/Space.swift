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
 
 - memory
 - model
 
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

/// Space is an object that provides working context to the graph memory.
/// A Space represents a problem or a project. Space associates a graph memory
/// with its semantic model.
///
/// ## Catalog
///
/// Space also provides a catalog of named nodes in the graph, usually
/// collections. Catalog is used to refer to objects of interest directly
/// without need of search for them.
///
/// To set names for objects in the catalog:
///
/// ```swift
/// let space: Space
/// let chapter: Node
///
/// space.catalog["Chapter 1"] = chapter
/// ```
///
/// To retrieve a named object from the catalog:
///
/// ```swift
/// let space: Space
/// let chapter = space.catalog["Chapter 1"]
///
/// ```
///
///
/// ## Persistence
///
/// Space can be persisted into a store and later loaded from the store. For
/// example to initialize a space from a file store:
///
/// ```swift
/// let dataURL = URL(fileURLWithPath: "Cards.tarot", isDirectory: true)
/// let store = try FilePackageStore(url: dataURL)
/// let space = try Space(store: store)
/// ```
///
/// Later we can persist the space into the store:
///
/// ```swift
/// try space.save(to: store)
///```
///
/// For further reading about stores read <doc:Persistence>
///
public class Space {
    /// Graph memory containing objects within the space.
    public let memory: GraphMemory
    
    /// Semantics of the graph memory.
    public let model: Model
    
    /// Node that represents the space's catalog - mapping of names to objects.
    /// Typically catalog items are collections.
    ///
    /// Catalog is a collection node.
    ///
    public var catalog: Dictionary? = nil
    
    /// Create an empty space with a given model.
    ///
    public init(model: Model? = nil) {
        memory = GraphMemory()
        if let model = model {
            self.model = model
        }
        else {
            self.model = Model(name: "__default", traits: [])
        }
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

    /// Write the whole space in a store.
    public func save(to store: PersistentStore) throws {
        // TODO: This is prone to corruption
        try store.deleteAll()
        
        // Write nodes
        // ---------------------------------------------------------------
        for node in memory.nodes {
            let id = String(node.id!)
            let record = StoreRecord(type: "node",  id: id, values: node.attributes)
            try store.save(record: record)
        }
        
        // Write links
        // ---------------------------------------------------------------
        for link in memory.links {
            let id = String(link.id!)
            let record = StoreRecord(type: "link", id: id, values: link.attributes)

            record[Space.originRecordKey] = .int(link.origin.id!)
            record[Space.targetRecordKey] = .int(link.target.id!)
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
    
    /// Read the whole space from a store.
    /// Create a space from a storage.
    ///

    public init(store: PersistentStore) throws {
        // FIXME: Model is not preserved here

        memory = GraphMemory()
        // Create an empty model for now
        // FIXME: Load the model from the store
        model = Model(name: "__default", traits: [])

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
            memory.add(node)
        }
        
        // Read links
        // ---------------------------------------------------------------
        for record in try store.fetchAll(type: "link") {
            let id = OID(record.id)

            // FIXME: Handle errors here instead of forcing unwrap
            let originID = OID(record[Self.originRecordKey]!.intValue()!)
            let targetID = OID(record[Self.targetRecordKey]!.intValue()!)

            let origin = memory.node(originID)!
            let target = memory.node(targetID)!
            
            var attributes: [String:Value] = [:]
            for key in record.keys {
                if key != Self.originRecordKey && key != Self.targetRecordKey {
                    attributes[key] = record[key]
                }
            }
            
            memory.connect(from: origin, to: target, attributes: attributes, id: id)
        }
    
        // FIXME: Handle errors here
        if let record = try store.fetch(id: "catalog") {
            let catalogNodeID = OID(record["node"]!.intValue()!)
            let node = memory.node(catalogNodeID)!
            catalog = Dictionary(node)
        }
        else {
            catalog = nil
        }
    }
    
}
