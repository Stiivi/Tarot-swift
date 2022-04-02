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
 
 - collections
    - custom created collections of nodes of assorted type
 - perspectives
    - custom collections of main nodes put into context of supportive nodes
 - views/projections/filters
    - 
 
 
 */

import Foundation
import Records


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
/// ## Saving and Loading
///
/// Graph can be persisted into a store and later loaded from the store. For
/// example to initialize a graph from a file store:
///
/// ```swift
/// let dataURL = URL(fileURLWithPath: "Cards.tarot")
/// let manager = try GraphManager(contentsOf: dataURL)
/// ```
///
/// Later we can persist the graph into the store:
///
/// ```swift
/// let writer = TarotFileWriter(url: dataURL)
/// try manager.save(using: writer)
///```
///
/// For more information about the file format see ``TarotFileWriter``
///
public class GraphManager {
    // TODO: Important: Rename to World
    
    /// Graph that the manager manages.
    ///
    public let graph: Graph
    
    /// Node that represents the graph's catalog - mapping of names to objects.
    /// Typically catalog items are collections.
    ///
    /// Catalog is a collection node.
    ///
    public var catalog: KeyedNeighbourhood? = nil
    
    /*
     
     World references:
     - catalog
     - model
     - everything_proxy
     - constraints
     - rules

     */
    
    /// Create a manager with an empty graph.
    ///
    public init() {
        graph = Graph()
    }
    
    
    public func save(using writer: GraphWriter) throws {
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
    
    
    /// Sets a new catalog node.
    public func setCatalog(_ node: Node) {
        guard node.graph === graph else {
            fatalError("Trying to set a catalog with a node from a different graph")
        }
        catalog = KeyedNeighbourhood(node, selector: LinkSelector("item"))
    }
    
}

