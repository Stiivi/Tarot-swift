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

    func testItems() throws {
        let collection = Collection(collectionNode)
        
        collectionNode["linkOrderAttribute"] = "order"
        XCTAssertEqual([nodes[2], nodes[1], nodes[0]], collection.items)
    }
    
}
