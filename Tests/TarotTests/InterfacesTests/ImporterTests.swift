//
//  ImporterTests.swift
//  GraphSpace
//
//  Created by Stefan Urbanek on 2021/10/7.
//

// TODO: Import links using namespace

import XCTest
@testable import TarotKit
@testable import Records

class TestNode: Node {
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
        try XCTSkipIf(true, "We are dealing with non-empty space here (has catalog)")

        let schema = Schema(["id", "name"], type: .string)
        let space = Space()
        let importer = PackageLoader(space: space)
        
        let record = Record(schema: schema, ["id": "1", "name": "one"])
        let name = try importer.importNode(record)
        let node = importer.namedNode(name)!
        
        let gnode = space.memory.nodes.first!
        
        XCTAssertIdentical(gnode, node)
    }
    
    func testMulti() throws {
        let schema = Schema(["id", "name"], type: .string)
        let space = Space()
        let loader = PackageLoader(space: space)

        let records = RecordSet(schema: schema, [
            Record(schema: schema, ["id":"1", "name": "one"]),
            Record(schema: schema, ["id":"2", "name": "two"]),
            Record(schema: schema, ["id":"3", "name": "three"]),
        ])
        
        let names = try loader.loadNodes(records: records).keys
        
        XCTAssertEqual(Set(names), ["1", "2", "3"])
    }
}
