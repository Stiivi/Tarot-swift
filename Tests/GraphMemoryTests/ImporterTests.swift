//
//  ImporterTests.swift
//  GraphSpace
//
//  Created by Stefan Urbanek on 2021/10/7.
//

import Foundation

import XCTest
@testable import GraphMemory
@testable import Records

class TestNode: Node, RecordRepresentable {
    var recordSchema: Schema { Schema() }
    
    let name: String
    init(name: String) {
        self.name = name
    }
    
    public required init(record: Record) throws {
        self.name = try record.stringValue(of: "name")!
    }
    
    public func recordRepresentation() -> Record {
        return Record(schema: Schema(["name"], type: .string))
    }
}

final class ImporterTests: XCTestCase {
    func testBase() throws {
        let schema = Schema(["id", "name"], type: .string)
        let space = GraphMemory()
        let importer = Importer(space: space)
        
        let record = Record(schema: schema, ["id": "1", "name": "one"])
        let node = try importer.importNode(record, type: TestNode.self)
        
        let gnode = space.nodes.first!
        
        XCTAssertIdentical(gnode, node)
    }
    
    func testMulti() throws {
        let schema = Schema(["id", "name"], type: .string)
        let space = GraphMemory()
        let importer = Importer(space: space)

        let records: [Record] = [
            Record(schema: schema, ["id":"1", "name": "one"]),
            Record(schema: schema, ["id":"2", "name": "two"]),
            Record(schema: schema, ["id":"3", "name": "three"]),
        ]
        
        for record in records {
            let node = try TestNode(record: record)
            try importer.importNode(record, type: TestNode.self)
        }
    }
}
