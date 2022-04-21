//
//  File.swift
//
//
//  Created by Stefan Urbanek on 30/12/2021.
//

import Foundation
import XCTest
@testable import TarotKit

final class KeyedNeighbourhoodTest: XCTestCase {
    var nodes: [Node]! = nil
    var graph: Graph! = nil
    var collectionNode: Node! = nil
    
    override func setUp() {
        graph = Graph()
        
        let nodeAttributes: [AttributeDictionary] = [
            ["name":"one", "number": "10"],
            ["name":"two", "number": "20"],
            ["name":"three", "number": "30"],
        ]
        
        nodes = []
        for attributes in nodeAttributes {
            let node = graph.create(attributes:attributes)
            nodes.append(node)
        }

        collectionNode = graph.create()

        graph.connect(from: collectionNode, to: nodes[0],
                      labels: ["item"],
                      attributes: ["key":"k1", "name": "jedna"])
        graph.connect(from: collectionNode, to: nodes[1],
                      labels: ["item"],
                      attributes: ["key":"k2", "name": "dva"])
        graph.connect(from: collectionNode, to: nodes[2],
                      labels: ["item"],
                      attributes: ["key":"k3", "name": "tri"])
    }
    func testDefaultLookup() throws {
        let dict = KeyedNeighbourhood(collectionNode, selector: LinkSelector("item"))
        
        XCTAssertEqual(dict.node(forKey: "k1"), nodes[0])
        XCTAssertEqual(dict.node(forKey: "k2"), nodes[1])
        XCTAssertEqual(dict.node(forKey: "k3"), nodes[2])

    }

    func testCustomKeyLookup() throws {
        let dict = KeyedNeighbourhood(collectionNode,
                                   selector: LinkSelector("item"),
                                   keyAttribute: "name")
        XCTAssertEqual(dict.node(forKey: "jedna"), nodes[0])
        XCTAssertEqual(dict.node(forKey: "dva"), nodes[1])
        XCTAssertEqual(dict.node(forKey: "tri"), nodes[2])

    }
    
    func testRemoveKey() throws {
        let dict = KeyedNeighbourhood(collectionNode, selector: LinkSelector("item"))

        XCTAssertEqual(dict.node(forKey: "k1"), nodes[0])
        dict.removeNode(forKey: "k1")
        XCTAssertNil(dict.node(forKey: "k1"))

    }
    func testSetKey() throws {
        let dict = KeyedNeighbourhood(collectionNode, selector: LinkSelector("item"))
        let node = graph.create()

        XCTAssertNil(dict.node(forKey: "new"))
        dict.setNode(node, forKey:"new")
        XCTAssertIdentical(dict.node(forKey:"new"), node)
    }
    func testLookupAfterObjectRemoval() throws {
        let dict = KeyedNeighbourhood(collectionNode, selector: LinkSelector("item"))

        XCTAssertEqual(dict.node(forKey: "k1"), nodes[0])
        graph.remove(nodes[0])
        XCTAssertNil(dict.node(forKey: "k1"))
    }
    func testKeys() throws {
        let dict = KeyedNeighbourhood(collectionNode, selector: LinkSelector("item"))
        let keys = dict.keys.compactMap { $0.stringValue() }
        XCTAssertEqual(Set(keys), Set(["k1", "k2", "k3"]))
    }
}
