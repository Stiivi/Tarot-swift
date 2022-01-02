//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/5.
//


/*

 Design notes:
 
 Space
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

/// Space represents a problem or a project. Space associates a graph memory
/// with its model as a semantics.
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
    public let catalog: Dictionary
    
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

        let catalogNode = Node()
        catalogNode["__system_object_name"] = "Catalog"
        memory.add(catalogNode)

        // FIXME: What happens if someone deletes the catalog node?
        catalog = Dictionary(catalogNode)
    }
    
    /// Create a space from a package. Populate the graph memory with nodes
    /// and links contained in the package.
    ///
    /// For more information see: `class:Package`
    public convenience init(packageURL: URL) throws {
        let package: Package
        
        // Load the package info from `info.json`
        //
        do {
            package = try Package(url: packageURL)
        }
        catch let error as CocoaError {
            if error.isFileError {
                let path = error.filePath!
                fatalError("Can not load package. File error: \(path)")
            }
            else {
                fatalError("Can not load package: \(error)")
            }
        }
        catch {
            fatalError("Can not load package '\(packageURL)': \(error)")
        }

        let model: Model
        // Try to load the package model from `model.json`
        //
        do {
            let json = try Data(contentsOf: package.modelURL)
            model = try JSONDecoder().decode(Model.self, from: json)
        }
        catch {
            fatalError("Can not read model resource: \(error)")
        }
        
        self.init(model: model)

        // Load the data
        // ---------------------------------------------------------------

        let loader = Loader(memory: self.memory)
        do {
            try loader.load(package: package, model: model)
        }
        catch let error as CocoaError {
            if error.isFileError {
                let path = error.filePath!
                fatalError("Can not load into graph memory. File error: \(path). Details: \(error)")
            }
            else {
                fatalError("Can not load into graph memory: \(error)")
            }
        }

    }
}


/// Store reading and writing.
///
extension Space {
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
    }
    
    /// Read the whole space from a store.
    /// Create a space from a storage.
    ///

    public convenience init(store: PersistentStore) throws {
        // FIXME: Model is not preserved here

        self.init()

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
        
    }
    
}
