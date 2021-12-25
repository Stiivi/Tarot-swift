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
    var tarot: Node?
    
    public init(dataURL: URL) throws {
        self.dataURL = dataURL

        // Load the model
        // ---------------------------------------------------------------
        let modelURL =  Bundle.module_WORKAROUND.url(forResource: "tarot-model",
                                                     withExtension: "json")
        let packageURL =  Bundle.module_WORKAROUND.url(forResource: "tarot-package",
                                                       withExtension: "json")

        do {
            let json = try Data(contentsOf: modelURL!)
            self.model = try JSONDecoder().decode(Model.self, from: json)
        }
        catch {
            fatalError("Can not read model resource: \(error)")
        }

        // Load the data
        // ---------------------------------------------------------------
        self.memory = GraphMemory()

        let loader = Loader(memory: self.memory)
        try loader.load(tabularPackage: packageURL!,
                        dataRoot: dataURL,
                        model: model)
    }

    public func __OLD__loadData() throws {
        print("Loading data ...")

        // 1. Create main Tarot node
        // ---------------------------------------------------------------
        let tarot = Node()
        
        guard let trait = model.trait(name: "Tarot") else {
            fatalError("Model has no trait 'Tarot'")
        }
        tarot.trait = trait
        
        self.tarot = tarot
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
            memory.connect(from: tarot, to: node, attributes:["name": "card"])
        }
        
        for node in indicators.values {
            memory.connect(from: tarot, to: node, attributes:["name": "indicator"])
        }

        for node in domains.values {
            memory.connect(from: tarot, to: node, attributes:["name": "domain"])
        }

        for node in relationships.values {
            memory.connect(from: tarot, to: node, attributes:["name": "relationshipType"])
        }

        for node in levels.values {
            memory.connect(from: tarot, to: node, attributes:["name": "level"])
        }
        
        // 4. Load relationships
        // ---------------------------------------------------------------
        print("Loading card relationships")
        try loadLinksCSV("relationships-main.csv", references: cards)
    }
    
    public func loadNodesCSV(_ filename: String,
                             fieldMap: [String:String]=[:]) throws -> [String:Node] {
        let url = dataURL.appendingPathComponent(filename)
        let loader = Loader(memory: memory)
        
        return try loader.loadNodes(contentsOfCSVFile: url)
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
        let importer = Loader(memory: memory)

        try importer.importLinksFromCSV(url)
    }
   
    
    public func writeDOT() {
        memory.writeDot(path: "/tmp/graph.dot", name: "cards")
        print("Done.")
    }
}
