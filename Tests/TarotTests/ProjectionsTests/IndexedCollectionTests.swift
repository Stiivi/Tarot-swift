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
    var graph: GraphMemory! = nil
    var collectionNode: Node! = nil
    
    override func setUp() {
        graph = GraphMemory()
        
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
    }
    func testAppend() throws {
        let collection = IndexedCollection(collectionNode,
                                           linkType:LabelledLinkType(label: "item"),
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
        let collection = IndexedCollection(collectionNode,
                                           linkType:LabelledLinkType(label: "item"),
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
