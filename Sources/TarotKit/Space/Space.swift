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
