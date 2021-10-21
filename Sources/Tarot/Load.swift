//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

import Foundation
import Records
import GraphMemory

func loadModel(_ dataPath: String, fileMap: [String:String]) throws {
    let dataURL = URL(fileURLWithPath: dataPath, isDirectory: true)
    let space = GraphMemory()
    var naming = ImporterNaming()
    
    naming.nodeKeyField = "name"
    
    let importer = Importer(space: space, naming: naming)

    // 1. Read cards
    // ---------------------------------------------------------------
    print("Loading cards...")

    let cardsURL = dataURL.appendingPathComponent(fileMap["cards"]!)
    try importer.importNodesFromCSV(cardsURL,
                                    namespace: "cards",
                                    type: Card.self,
                                    fieldMap:[
                                        "engineering power": "engPower",
                                        "compute power": "compPower"
                                    ])
    // 2. Read indicators
    // ---------------------------------------------------------------

    print("Loading indicators...")
    let statsURL = dataURL.appendingPathComponent(fileMap["stats"]!)
    try importer.importNodesFromCSV(statsURL,
                                    namespace: "cards",
                                    type: Indicator.self)

    // 2. read and validate Card relationships
    // ---------------------------------------------------------------

    print("Loading card relationships...")
    let linksURL = dataURL.appendingPathComponent(fileMap["links"]!)
    try importer.importLinksFromCSV(linksURL, namespace:"cards")
}
