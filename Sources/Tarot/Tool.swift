//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/24.
//

import GraphMemory
import Foundation

// Main

class TarotTool {
    let dataURL: URL
    let memory: GraphMemory
    let model: Model
    let naming: ImporterNaming
    
    public init(dataURL: URL) throws {
        self.dataURL = dataURL

        // We are using 'name' as an ID field for usability
        //
        var naming = ImporterNaming()
        naming.nodeKeyField = "name"
        
        self.naming = naming
        
        self.memory = GraphMemory()

        // Load Model
        // ---------------------------------------------------------------
        let modelURL =  Bundle.module_WORKAROUND.url(forResource: "model", withExtension: "json")
        let json = try Data(contentsOf: modelURL!)
        model = try JSONDecoder().decode(Model.self, from: json)
    }
    
    public func loadData() throws {
        print("Loading data ...")

        // 1. Create main Tarot node
        // ---------------------------------------------------------------
        let tarot = Node()
        memory.add(tarot)

        // 2. Import nodes
        // ---------------------------------------------------------------
        
        print("Loading cards")
        let cards = try loadNodesCSV("cards-main.csv",
                                     fieldMap: [
                                         "engineering power": "engineeringPower",
                                         "compute power": "compuptePower"
                                     ])
        print("Loading indicators")
        let indicators = try loadNodesCSV("types-stats.csv")
        print("Loading domains")
        let domains = try loadNodesCSV("types-domains.csv")
        print("Loading relationships")
        let relationships = try loadNodesCSV("types-relationships.csv")
        print("Loading levels")
        let levels = try loadNodesCSV("levels-levels.csv")

        // 3. Connect cards to tarot
        // ---------------------------------------------------------------
        print("Connecting cards and other nodes")
        for node in cards.values {
            memory.connect(from: tarot, to: node, at: "card")
        }
        
        for node in indicators.values {
            memory.connect(from: tarot, to: node, at: "indicator")
        }

        for node in domains.values {
            memory.connect(from: tarot, to: node, at: "domain")
        }

        for node in relationships.values {
            memory.connect(from: tarot, to: node, at: "relationshipType")
        }

        for node in levels.values {
            memory.connect(from: tarot, to: node, at: "level")
        }
        
        // 4. Load relationships
        // ---------------------------------------------------------------
        print("Loading card relationships")
        try loadLinksCSV("relationships-main.csv", references: cards)
    }
    
    public func loadNodesCSV(_ filename: String,
                             trait traitName: String?=nil,
                             fieldMap: [String:String]=[:]) throws -> [String:Node] {
        let url = dataURL.appendingPathComponent(filename)
        let importer = Importer(memory: memory, naming: naming)
        let trait: Trait?
        
        if let traitName = traitName {
            trait = model.trait(name: traitName)
        }
        else {
            trait = nil
        }
        
        return try importer.importNodesFromCSV(url,
                                               trait: trait,
                                               fieldMap: fieldMap)
    }
    
    /// Loads links from a CSV file into the graph memory.
    ///
    /// - Parameters:
    ///
    ///     - filename: Filename in the ``dataURL`` directory.
    ///     - references: A dictionary of node references where keys are node
    ///       keys (or names) that are used in the origins and target fields in
    ///       the source file. Values are nodes.
    ///
    public func loadLinksCSV(_ filename: String, references: [String:Node]) throws {
        let url = dataURL.appendingPathComponent(filename)
        let importer = Importer(memory: memory,
                                naming: naming,
                                references: references)

        try importer.importLinksFromCSV(url)
    }
    
    public func writeDOT() {
        memory.writeDot(path: "/tmp/graph.dot", name: "cards")
        print("Done.")
    }
}
