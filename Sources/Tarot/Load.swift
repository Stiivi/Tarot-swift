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
    fatalError("loadModel without importer is deprecated")
    let dataURL = URL(fileURLWithPath: dataPath, isDirectory: true)
    let space = GraphMemory()
    
    var issues: [String] = []
    
    print("Validating data...")
    // 1. Read and validate Cards
    // ---------------------------------------------------------------

    guard let cardRecords = try RecordSet(contentsOfCSVFile: dataURL.appendingPathComponent(fileMap["cards"]!)) else {
        fatalError("Can not load card records")
    }
       
    issues += validateNodeRecords(cardRecords, idField: "name")
    
    cardRecords.schema = cardRecords.schema.renamed([
        "engineering power": "engPower",
        "compute power": "compPower",
    ])
    
    let diff = cardRecords.schema.difference(with: Card.recordSchema)
    
    if diff.missingFields.count > 0 {
        issues.append("Cards file is missing fields: \(diff.missingFields)")
    }

    let cardIDs = cardRecords.distinctValues(of: "name")

    // 2. read and validate Card relationships
    // ---------------------------------------------------------------

    guard let linkRecords = try RecordSet(contentsOfCSVFile: dataURL.appendingPathComponent(fileMap["links"]!)) else {
        fatalError("Can not load link records")
    }
        
    issues += validateLinkRecords(linkRecords, nodeIDs: cardIDs, originField: "origin", targetField: "target", nameField: "name")

    // 3. read and validate Stats
    // ---------------------------------------------------------------

    guard let statsRecords = try RecordSet(contentsOfCSVFile: dataURL.appendingPathComponent(fileMap["stats"]!)) else {
        fatalError("Can not load stats records")
    }
       
    issues += validateNodeRecords(cardRecords, idField: "name")

    let statIDs = cardRecords.distinctValues(of: "name")

    
    // VALIDATION RESULTS
    // ---------------------------------------------------------------
    guard issues.count == 0 else {
        print("ISSUES:")
        for issue in issues {
            print(issue)
        }
        return
    }

    print("Populating space...")
    
    // Import nodes to the graph
    // ---------------------------------------------------------------
    var cards: [String:Card] = [:]
    
    for record in cardRecords {
        let card = try Card(record:record)
        space.associate(card)
        cards[card.name] = card
    }
    
    for record in linkRecords {
        let origin: Card = cards[record["origin"]!.stringValue()!]!
        let target: Card = cards[record["target"]!.stringValue()!]!
        let name: String = record["name"]!.stringValue()!
        space.connect(from: origin, to: target, at: name)
    }
}

func loadModelUsingImporter(_ dataPath: String, fileMap: [String:String]) throws -> IssueList {
    var issues = IssueList()
    let dataURL = URL(fileURLWithPath: dataPath, isDirectory: true)
    let space = GraphMemory()
    var naming = ImporterNaming()
    
    naming.nodeKeyField = "name"
    
    let importer = Importer(space: space, naming: naming)

    // 1. Read and validate Cards
    // ---------------------------------------------------------------

    print("Reading cards...")
    guard let cardRecords = try RecordSet(contentsOfCSVFile: dataURL.appendingPathComponent(fileMap["cards"]!)) else {
        fatalError("Can not load card records")
    }
           
    cardRecords.schema = cardRecords.schema.renamed([
        "engineering power": "engPower",
        "compute power": "compPower",
    ])
    
    print("Validating cards...")
    issues += importer.validateNodeRecords(cardRecords, type: Card.self)

    guard !issues.hasErrors else {
        return issues
    }
    
    print("Importing cards...")
    issues += importer.importNodes(cardRecords, namespace: "cards", type: Card.self)
    guard !issues.hasErrors else {
        return issues
    }
    
    // 2. read and validate Card relationships
    // ---------------------------------------------------------------

    print("Reading card relationships...")
    guard let linkRecords = try RecordSet(contentsOfCSVFile: dataURL.appendingPathComponent(fileMap["links"]!)) else {
        fatalError("Can not load link records")
    }

    print("Validating card relationships...")
    issues += importer.validateLinkRecords(linkRecords, namespace: "cards")

    return issues
}
