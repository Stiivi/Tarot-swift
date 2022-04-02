//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 12/01/2022.
//

import Foundation
import XCTest
@testable import TarotKit


final class IndexedCollectionTests: XCTestCase {
    var nodes: [Node]! = nil
    var graph: Graph! = nil
    var collectionNode: Node! = nil
    
    override func setUp() {
        graph = Graph()
        
        let nodeAttributes:[AttributeDictionary] = [
            ["name":"one", "number": "10"],
            ["name":"two", "number": "20"],
            ["name":"three", "number": "30"],
            ]
        
        nodes = []
        
        for attributes in nodeAttributes {
            nodes.append(graph.create(attributes:attributes))
        }

        collectionNode = graph.create()
    }
    
    func testAppend() throws {
        let collection = IndexedNeighbourhood(collectionNode,
                                           selector:LinkSelector("item"),
                                           indexAttribute: "index")

        XCTAssertEqual(collection.count, 0)
        XCTAssertEqual(collection.endIndex, 0)

        collection.append(nodes[0])
        XCTAssertEqual(collection.count, 1)
        XCTAssertEqual(collection.endIndex, 1)

        collection.append(nodes[1])
        XCTAssertEqual(collection.count, 2)
        XCTAssertEqual(collection.endIndex, 2)

        collection.append(nodes[2])
        XCTAssertEqual(collection.count, 3)
        XCTAssertEqual(collection.endIndex, 3)
        XCTAssertEqual(collection.nodes, [nodes[0], nodes[1], nodes[2]])

        collection.append(nodes[2])
        XCTAssertEqual(collection.count, 4)
        XCTAssertEqual(collection.endIndex, 4)

        XCTAssertEqual(collection.nodes, [nodes[0], nodes[1], nodes[2], nodes[2]])
    }
    
    func testNodeAt() throws {
        let collection = IndexedNeighbourhood(collectionNode,
                                           selector:LinkSelector("item"),
                                           indexAttribute: "index")
        collection.append(nodes[0])
        collection.append(nodes[1])
        collection.append(nodes[2])
        XCTAssertEqual(collection.node(at: 0), nodes[0])
        XCTAssertEqual(collection.node(at: 1), nodes[1])
        XCTAssertEqual(collection.node(at: 2), nodes[2])
        collection.append(nodes[2])
        XCTAssertEqual(collection.node(at: 3), nodes[2])

    }
}
