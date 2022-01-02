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
    func testBasic() throws {
        let graph = GraphMemory()
        
        let nodes = [
            Node(attributes: ["name":"one", "number": "10"]),
            Node(attributes: ["name":"two", "number": "20"]),
            Node(attributes: ["name":"three", "number": "30"]),
            ]
        
        for node in nodes {
            graph.add(node)
        }
        
        let collectionNode = Node(
            attributes: ["itemLinkAttribute": "label",
                        "itemLinkValue": "item",
                        "linkSortAttribute": "order"]
        )
        graph.add(collectionNode)

        graph.connect(from: collectionNode, to: nodes[0], attributes: ["label":"item", "order": 3])
        graph.connect(from: collectionNode, to: nodes[1], attributes: ["label":"item", "order": 2])
        graph.connect(from: collectionNode, to: nodes[2], attributes: ["label":"item", "order": 1])

        let collection = Collection(collectionNode)
        
        XCTAssertEqual([nodes[2], nodes[1], nodes[0]], collection.items)

    }
}
