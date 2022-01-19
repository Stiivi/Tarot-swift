//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 19/01/2022.
//

import Foundation

/// Writes a graph into a JSON file. This is the default storage format
/// for the TarotKit.
///
/// The file is a JSON file containing a dictionary with the following keys:
///
/// - `info` – metadata about the store, such as version of the writing
///    object
/// - `nodes` – an array with nodes
/// - `links` – an array with links
/// - `names` – named references
///
/// The info dictionary has the following keys:
///
/// - `format_version` – version of the format
///
/// The nodes have the following structure:
///
/// - `id`: node ID
/// - `attributes`: a dictionary with node attributes
///
/// The links have the following structure:
///
/// - `id`: link ID
/// - `origin`: ID of the link origin node
/// - `target`: ID of the link target node
/// - `attributes`: a dictionary with link attributes
///
/// The `names` is a dictionary where the key is a node name and the value is
/// ID of the node with the given name.
///
/// - Note: This store is not optimized for performance neither robustness. Any
///         external changes to the store might corrupt the store's integrity.
///
public class TarotFileWriter: GraphWriter {
    static let writerVersion = 100
    
    /// URL of the output file
    let outputURL: URL
    
    public init(url: URL) {
        self.outputURL = url
    }
    
    func objectToDict(_ object: Object) -> [String:Any] {
        guard let id = object.id else {
            fatalError("Trying to write an object without an ID")
        }
        
        // We create a JSON serializable record – a dictionary.
        //
        var attributes: [String:Any] = [:]
        
        for key in object.attributes.keys {
            attributes[key] = object[key]?.anyValue()
        }
        
        let dict: [String:Any] = [
            // We are storing all IDs as strings.
            "id": String(id),
            "attributes": attributes
        ]
        return dict
    }
    
    public func write(graph: Graph, names: [String:Node] = [:]) throws {
        var namedReferences: [String:String] = [:]
        var nodes: [[String:Any]] = []
        var links: [[String:Any]] = []
        let info: [String:Any] = [
            "version": TarotFileWriter.writerVersion
        ]
        
        for node in graph.nodes {
            let dict = objectToDict(node)
            nodes.append(dict)
        }
        for link in graph.links {
            var dict = objectToDict(link)
            dict["origin"] = String(link.origin.id!)
            dict["target"] = String(link.target.id!)
            links.append(dict)
        }
        
        for (name, node) in names {
            guard let id = node.id else {
                fatalError("Trying to write a name reference (\(name))to an object without an ID")
            }
            namedReferences[name] = String(id)
        }
        
        let dict:[String:Any] = [
            "info": info,
            "nodes": nodes,
            "links": links,
            "names": namedReferences
        ]
        
        // Create data and write to a file
        let data: Data = try JSONSerialization.data(withJSONObject: dict)
        try data.write(to: outputURL,options: .atomic)
    }
}
