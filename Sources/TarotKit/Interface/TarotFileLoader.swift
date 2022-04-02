//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 19/01/2022.
//

import Foundation
import Records

/// Loads a graph from a Tarot file.
///
/// Tarot file is a JSON file with a specific format described in ``TarotFileWriter``.
///
public class TarotFileLoader: Loader {
    // TODO: Use this also as a loader that does not preserve IDs when loading
    
    public let graph: Graph

    // All IDs are stored as string, so we map the ID strings to nodes, not
    // the original ID type.
    /// Mapping between internally stored IDs and nodes
    var index: [String:Node] = [:]
    
    /// Create a new loader that loads the graph from the given URL. The URL
    /// sohuld point to a resource with JSON that has a structure described
    /// in the ``TarotFileWriter``.
    ///
    public required init(graph: Graph) {
        self.graph = graph
    }

    /// Loads the graph stored in the file into the graph. Returns a mapping
    /// of mapped nodes.
    ///
    public func load(from source: URL, preserveIdentity: Bool) throws -> [String:Node] {
        let data = try Data(contentsOf: source)
        return try load(from: data,
                        preserveIdentity: preserveIdentity,
                        source: source)
    }
        
    /// Loads the graph stored in JSON data. Returns a mapping
    /// of mapped nodes.
    ///
    public func load(from data: Data, preserveIdentity: Bool, source: URL?=nil) throws -> [String:Node] {
        // Deserialize the JSON object. We are assuming the object be
        // a dictionary. We crash if the stored object is not a dictionary
        // as it is considered to be a corrupted store.
        //
        let content = try JSONSerialization.jsonObject(with: data) as! [String:Any]

        guard let info = content["info"] as? [String:Any] else {
            // TODO: Throw error
            let sourceStr = source.map { $0.absoluteString } ?? "(no source provided)"
            fatalError("Invalid content: no info dictionary. Graph source: \(sourceStr)")
        }
        
        guard info["version"] as? Int == 100 else {
            let sourceStr = source.map { $0.absoluteString } ?? "(no source provided)"
            fatalError("Invalid version: \(info["version"] ?? "(no version)"). Graph source: \(sourceStr)")
        }
        
        guard let nodes = content["nodes"] as? [[String:Any]] else {
            let sourceStr = source.map { $0.absoluteString } ?? "(no source provided)"
            fatalError("Invalid or missing nodes data. Graph source: \(sourceStr)")
        }

        guard let links = content["links"] as? [[String:Any]] else {
            let sourceStr = source.map { $0.absoluteString } ?? "(no source provided)"
            fatalError("Invalid or missing links data. Graph source: \(sourceStr)")
        }
        
        guard let sourceNames = content["names"] as? [String:String] else {
            let sourceStr = source.map { $0.absoluteString } ?? "(no source provided)"
            fatalError("Invalid or missing names data. Graph source: \(sourceStr)")
        }

        for node in nodes {
            try load(node: node, into: graph, preserveIdentity: preserveIdentity)
        }

        for link in links {
            try load(link: link, into: graph, preserveIdentity: preserveIdentity)
        }

        var names: [String:Node] = [:]
        
        for (name, idString) in sourceNames {
            guard let node = index[idString] else {
                throw LoaderError.unknownNode(.string(idString), "default")
            }
            names[name] = node
        }
        
        return names
    }
    
    public func load(node dict: [String:Any], into graph: Graph, preserveIdentity: Bool) throws {
        guard let idString = dict["id"] as? String else {
            throw LoaderError.missingSourceID("nodes")
        }
        guard index[idString] == nil else {
            throw LoaderError.duplicateSourceID(.string(idString), "default")
        }
        
        guard let idValue = Int(idString) else {
            throw LoaderError.sourceIDTypeMismatch(.string(idString), "default")
        }
        let id = OID(idValue)
        
        var attributes: AttributeDictionary = [:]
        for (key, value) in dict["attributes"] as! [String:Any] {
            attributes[key] = Value(any: value)
        }
        
        let node: Node
        
        if preserveIdentity {
            node = graph.create(attributes: attributes, id: id)
        }
        else {
            node = graph.create(attributes: attributes)
        }
        index[idString] = node
    }

    public func load(link dict: [String:Any], into graph: Graph, preserveIdentity: Bool) throws {
        // TODO: Check duplicate IDs
        guard let idString = dict["id"] as? String else {
            throw LoaderError.missingSourceID("default")
        }
        guard let idValue = Int(idString) else {
            throw LoaderError.sourceIDTypeMismatch(.string(idString), "links")
        }
        let id = OID(idValue)
        
        var attributes: AttributeDictionary = [:]
        for (key, value) in dict["attributes"] as! [String:Any] {
            attributes[key] = Value(any: value)
        }

        guard let originKey = dict["origin"] as? String else {
            fatalError("Invalid origin '\(dict["origin"] ?? "(no origin)")' in link ID:\(idString)")
        }
        guard let targetKey = dict["target"] as? String else {
            fatalError("Invalid target '\(dict["target"] ?? "(no origin)")' in link ID:\(idString)")
        }
        guard let origin = index[originKey] else {
            fatalError("Unknown origin reference '\(originKey)' in link ID:\(idString)")
        }
        guard let target = index[targetKey] else {
            fatalError("Unknown target reference '\(targetKey)' in link ID:\(idString)")
        }
        
        graph.connect(from: origin, to: target, attributes: attributes, id: id)
    }

}
