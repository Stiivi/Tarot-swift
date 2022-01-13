//
//  File.swift
//
//
//  Created by Stefan Urbanek on 30/12/2021.
//

import Foundation
import XCTest
@testable import TarotKit

final class DictionaryTests: XCTestCase {
    var nodes: [Node]! = nil
    var graph: Graph! = nil
    var collectionNode: Node! = nil
    
    override func setUp() {
        graph = Graph()
        
        nodes = [
            Node(attributes: ["name":"one", "number": "10"]),
            Node(attributes: ["name":"two", "number": "20"]),
            Node(attributes: ["name":"three", "number": "30"]),
            ]
        
        for node in nodes {
            graph.add(node)
        }

        collectionNode = Node()
        graph.add(collectionNode)

        graph.connect(from: collectionNode, to: nodes[0],
                      attributes: ["label":"item", "key":"k1", "name": "jedna"])
        graph.connect(from: collectionNode, to: nodes[1],
                      attributes: ["label":"item", "key":"k2", "name": "dva"])
        graph.connect(from: collectionNode, to: nodes[2],
                      attributes: ["label":"item", "key":"k3", "name": "tri"])
    }
    func testDefaultLookup() throws {
        let dict = Dictionary(collectionNode)
        
        XCTAssertEqual(dict.item(key: "k1"), nodes[0])
        XCTAssertEqual(dict.item(key: "k2"), nodes[1])
        XCTAssertEqual(dict.item(key: "k3"), nodes[2])

    }

    func testCustomKeyLookup() throws {
        let dict = Dictionary(collectionNode)
        collectionNode["keyLinkAttribute"] = "name"
        
        XCTAssertEqual(dict.item(key: "jedna"), nodes[0])
        XCTAssertEqual(dict.item(key: "dva"), nodes[1])
        XCTAssertEqual(dict.item(key: "tri"), nodes[2])

    }
    
    func testRemoveKey() throws {
        let dict = Dictionary(collectionNode)
        
        XCTAssertEqual(dict.item(key: "k1"), nodes[0])
        dict.removeKey("k1")
        XCTAssertNil(dict.item(key: "k1"))

    }
    func testSetKey() throws {
        let dict = Dictionary(collectionNode)
        let node = Node()

        graph.add(node)
        XCTAssertNil(dict.item(key: "new"))
        dict.setKey("new", for: node)
        XCTAssertIdentical(dict.item(key:"new"), node)
    }
    func testLookupAfterObjectRemoval() throws {
        let dict = Dictionary(collectionNode)
        
        XCTAssertEqual(dict.item(key: "k1"), nodes[0])
        graph.remove(nodes[0])
        XCTAssertNil(dict.item(key: "k1"))
    }
}
