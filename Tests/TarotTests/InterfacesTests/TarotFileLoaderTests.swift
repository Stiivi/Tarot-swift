//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 19/01/2022.
//

import XCTest
@testable import TarotKit
@testable import Records

final class TarotFileLoaderTests: XCTestCase {
    var graph: Graph!
    
    override func setUp() {
        self.graph = Graph()
    }
    
    func testEmpty() throws {
        let text = """
                   {
                   "info": { "version": 100 },
                   "nodes": [],
                   "links": [],
                   "names": {}
                   }
                   """
        let data = text.data(using: .utf8)!
        let loader = TarotFileLoader(graph: graph)
        
        let names = try loader.load(from: data, preserveIdentity: true)
        
        XCTAssertEqual(names.count, 0)
        
        XCTAssertEqual(graph.nodes.count, 0)
        XCTAssertEqual(graph.links.count, 0)
    }

    func testNodes() throws {
        let text = """
                   {
                   "info": { "version": 100 },
                   "nodes": [
                   { "id": "1", "attributes": {"name": "one"}},
                   { "id": "2", "attributes": {"name": "two"}},
                   { "id": "3", "attributes": {"name": "three"}}
                   ],
                   "links": [],
                   "names": {
                       "one": "1",
                       "two": "2",
                       "three": "3"
                   }
                   }
                   """
        let data = text.data(using: .utf8)!
        let loader = TarotFileLoader(graph: graph)
        
        let names = try loader.load(from: data, preserveIdentity: true)
        
        XCTAssertEqual(names.count, 3)
        XCTAssertEqual(Set(names.keys), Set(["one", "two", "three"]))

        let ids = Set(graph.nodes.map { $0.id })
        let values = Set(graph.nodes.map { $0["name"]! })
        
        XCTAssertEqual(ids, Set([1,2,3]))
        XCTAssertEqual(values, Set(["one", "two", "three"]))
        XCTAssertEqual(graph.nodes.count, 3)
        XCTAssertEqual(graph.links.count, 0)
    }
    func testLinks() throws {
        let text = """
                   {
                   "info": { "version": 100 },
                   "nodes": [
                   { "id": "1", "attributes": {"name": "one"}},
                   { "id": "2", "attributes": {"name": "two"}},
                   { "id": "3", "attributes": {"name": "three"}}
                   ],
                   "links": [
                   { "id": "4", "origin": "1", "target": "2", "attributes": {"label": "next"}},
                   { "id": "5", "origin": "2", "target": "3", "attributes": {"label": "last"}}
                   ],
                   "names": {
                       "one": "1",
                       "two": "2",
                       "three": "3"
                   }
                   }
                   """
        let data = text.data(using: .utf8)!
        let loader = TarotFileLoader(graph: graph)
        
        let names = try loader.load(from: data, preserveIdentity: true)
        
        XCTAssertEqual(names.count, 3)

        let one = names["one"]!
        let two = names["two"]!
        let three = names["three"]!

        XCTAssertEqual(one.outgoing.count, 1)
        let linkOne = one.outgoing.first!
        XCTAssertIdentical(linkOne.origin, one)
        XCTAssertIdentical(linkOne.target, two)
        
        XCTAssertEqual(linkOne["label"]!, "next")

        XCTAssertEqual(two.outgoing.count, 1)
        let linkTwo = two.outgoing.first!
        XCTAssertIdentical(linkTwo.origin, two)
        XCTAssertIdentical(linkTwo.target, three)
        XCTAssertEqual(linkTwo["label"]!, "last")

        XCTAssertEqual(three.outgoing.count, 0)
    }
}
