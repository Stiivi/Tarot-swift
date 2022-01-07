//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 07/01/2022.
//

import XCTest
@testable import TarotKit
@testable import Records


final class RelationalPackageLoaderTests: XCTestCase {
    var space: Space!
    var graph: GraphMemory!
    
    override func setUp() {
        self.space = Space()
        self.graph = space.memory
    }
    
    func testLoadRecordPrimaryKey() throws {
        let loader = RelationalPackageLoader(space: space)
        let emptyRecord = Record([:])
        let validRecord = Record(["id":"1"])
        let customRecord = Record(["key":"1"])
        
        let defaultRelation = NodeRelation(name: "nodes")
        let customRelation = NodeRelation(name: "nodes", primaryKey: "key")

        XCTAssertNoThrow {
            try loader.loadNode(validRecord, relation: defaultRelation)
        }
        XCTAssertNoThrow {
            try loader.loadNode(customRecord, relation: customRelation)
        }

        XCTAssertThrowsError(try loader.loadNode(emptyRecord,
                                             relation: defaultRelation),
                             "Should throw error on no primary key") {
            XCTAssertEqual($0 as! LoaderError, LoaderError.missingPrimaryKey("nodes"))
        }
        XCTAssertThrowsError(try loader.loadNode(customRecord,
                                             relation: defaultRelation),
                             "Should throw error on no primary key") {
            XCTAssertEqual($0 as! LoaderError, LoaderError.missingPrimaryKey("nodes"))
        }

    }
    func testDuplicateKey() throws {
        let loader = RelationalPackageLoader(space: space)
        let record = Record(["id":"1"])
        let relation = NodeRelation(name: "nodes")

        
        XCTAssertNil(loader.node(forKey: "1", relation: "nodes"))
        let node = try loader.loadNode(record, relation: relation)
        XCTAssertIdentical(loader.node(forKey: "1", relation: "nodes"), node)
        
        // Load another node with the same key
        XCTAssertThrowsError(try loader.loadNode(record, relation: relation),
                             "Should throw error on duplicate key") {
            XCTAssertEqual($0 as! LoaderError, LoaderError.duplicateKey("1", "nodes"))
        }
    }
    
    func testLoadRecord() throws {
        let loader = RelationalPackageLoader(space: space)
        let record = Record(["id":"1", "name": "one"])
        let relation = NodeRelation(name: "nodes")

        
        let node = try loader.loadNode(record, relation: relation)

        XCTAssertEqual(node["id"], record["id"])
        XCTAssertEqual(node["name"], record["name"])
        
        XCTAssertEqual(graph.nodes.count, 1)
        XCTAssertIdentical(graph.nodes.first!, node)
    }
    
    func testLoadLink() throws {
        let loader = RelationalPackageLoader(space: space)
        let nodeRelation = NodeRelation(name: "nodes")
        let linkRelation = LinkRelation(name: "link", originRelation: "nodes")
        let originRecord = Record(["id":"1", "name": "one"])
        let targetRecord = Record(["id":"2", "name": "two"])
        let linkRecord = Record(["origin":"1", "target": "2", "label": "next"])
        
        let origin = try loader.loadNode(originRecord, relation: nodeRelation)
        let target = try loader.loadNode(targetRecord, relation: nodeRelation)
        let link = try loader.loadLink(linkRecord, relation: linkRelation)
        
        XCTAssertIdentical(link.origin, origin)
        XCTAssertIdentical(link.target, target)

        // The attributes must be preserved
        XCTAssertEqual(link["label"], "next")

        // The reference field must be removed
        XCTAssertNil(link["origin"])
        XCTAssertNil(link["target"])
    }
    
    func testLoadLinkDifferentRelation() throws {
        let loader = RelationalPackageLoader(space: space)
        let originRelation = NodeRelation(name: "nodes")
        let originRecord = Record(["id":"1", "name": "one"])

        let targetRelation = NodeRelation(name: "colors")
        let targetRecord = Record(["id":"1", "name": "yellow"])

        let linkRelation = LinkRelation(name: "link",
                                        originRelation: "nodes",
                                        targetRelation: "colors")
        let linkRecord = Record(["origin":"1", "target": "1", "label": "color"])
        
        let origin = try loader.loadNode(originRecord, relation: originRelation)
        let target = try loader.loadNode(targetRecord, relation: targetRelation)
        let link = try loader.loadLink(linkRecord, relation: linkRelation)
        
        XCTAssertIdentical(link.origin, origin)
        XCTAssertIdentical(link.target, target)

        XCTAssertEqual(link.origin["name"], "one")
        XCTAssertEqual(link.target["name"], "yellow")
    }

    func testLoadLinks() throws {
        let loader = RelationalPackageLoader(space: space)
        let nodeRecords = RecordSet(
            schema: Schema(["id", "name"]),
            [
            Record(["id":"1", "name": "one"]),
            Record(["id":"2", "name": "two"]),
            Record(["id":"3", "name": "three"]),
            ])
        let nodeRelation = NodeRelation(name: "nodes")

        let linkRecords = RecordSet(
            schema: Schema(["origin", "target", "label"]),
            [
            Record(["origin":"1", "target": "2", "label": "next"]),
            Record(["origin":"2", "target": "3", "label": "next"]),
            ])
        let linkRelation = LinkRelation(name: "link", originRelation: "nodes")
        
        let nodes = try loader.loadNodes(nodeRecords, relation: nodeRelation)
        let links = try loader.loadLinks(linkRecords, relation: linkRelation)
        
        // This is a poor test, but at least something
        XCTAssertEqual(nodes.count, 3)
        XCTAssertEqual(links.count, 2)

        XCTAssertEqual(graph.nodes.count, 3)
        XCTAssertEqual(graph.links.count, 2)
    }

}
