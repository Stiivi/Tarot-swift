//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 30/12/2021.
//

import Foundation
import XCTest
@testable import TarotKit

final class CollectionTests: XCTestCase {
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

        graph.connect(from: collectionNode, to: nodes[0],
                      attributes: ["label":"item", "order":3])
        graph.connect(from: collectionNode, to: nodes[1],
                      attributes: ["label":"item", "order":2])
        graph.connect(from: collectionNode, to: nodes[2],
                      attributes: ["label":"item", "order":1])
    }

    func testCount() throws {
        let collection = Collection(collectionNode)
        XCTAssertEqual(collection.count, 3)
    }
    
    func testItems() throws {
        let collection = Collection(collectionNode)
        
        collectionNode["linkOrderAttribute"] = "order"
        
        let links = collection.orderedItemLinks()
        let items = links.map { $0.target }
        XCTAssertEqual(items, [nodes[2], nodes[1], nodes[0]])
    }
    
}
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
        let collection = IndexedCollection(collectionNode)
        
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
        XCTAssertEqual(collection.items, [nodes[0], nodes[1], nodes[2]])

        collection.append(nodes[2])
        XCTAssertEqual(collection.count, 4)
        XCTAssertEqual(collection.endIndex, 4)

        XCTAssertEqual(collection.items, [nodes[0], nodes[1], nodes[2], nodes[2]])
    }
    
    func testNodeAt() throws {
        let collection = IndexedCollection(collectionNode)
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
