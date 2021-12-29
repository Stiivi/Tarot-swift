//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/5.
//

import Foundation


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

import GraphMemory
import Interface

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
    
    /// Create an empty space with a given model.
    ///
    public init(model: Model) {
        memory = GraphMemory()
        self.model = model
    }
    
    /// Create a space from a package. Populate the graph memory with nodes
    /// and links contained in the package.
    ///
    /// For more information see: `class:Package`
    public init(packageURL: URL) throws {
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

        // Try to load the package model from `model.json`
        //
        do {
            let json = try Data(contentsOf: package.modelURL)
            self.model = try JSONDecoder().decode(Model.self, from: json)
        }
        catch {
            fatalError("Can not read model resource: \(error)")
        }

        // Create the memory
        memory = GraphMemory()
        
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
