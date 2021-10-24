//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

import Foundation
import Records
import GraphMemory

func loadModel(_ space: GraphMemory, _ dataPath: String, fileMap: [String:String]) throws {
    let dataURL = URL(fileURLWithPath: dataPath, isDirectory: true)
    var naming = ImporterNaming()
    
    naming.nodeKeyField = "name"
    
    let importer = Importer(memory: space, naming: naming)

    // 4. Create "tarot"
    // ---------------------------------------------------------------
    
    let tarot = Node()
    space.add(tarot)
    
    // 1. Read cards
    // ---------------------------------------------------------------
    print("Loading cards...")

    // FIXME: The below action call looks unreadable, think of something nicer
    let cardsURL = dataURL.appendingPathComponent(fileMap["cards"]!)
    try importer.importNodesFromCSV(cardsURL, namespace: "cards", type: Card.self,
                                    fieldMap:[
                                        "engineering power": "engPower",
                                        "compute power": "compPower"
                                    ]) { name, card in
        space.connect(from: tarot, to: card, at: "card")
    }
    // 2. Read indicators
    // ---------------------------------------------------------------

    print("Loading indicators...")
    let statsURL = dataURL.appendingPathComponent(fileMap["stats"]!)
    try importer.importNodesFromCSV(statsURL, namespace: "cards", type: Indicator.self)

    // 3. read and validate Card relationships
    // ---------------------------------------------------------------

    print("Loading card relationships...")
    let linksURL = dataURL.appendingPathComponent(fileMap["links"]!)
    try importer.importLinksFromCSV(linksURL, namespace:"cards")
    
}
