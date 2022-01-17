//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 17/01/2022.
//

import Foundation
import XCTest
@testable import TarotKit

final class OutlineTests: XCTestCase {
    var nodes: [Int:Node]!
    var outlineNode: Node!
    var graph: Graph!
    
    override func setUp() {
        graph = Graph()
        let nodes = [
            1: Node(attributes: ["name":"one", "number": "1"]),
            2: Node(attributes: ["name":"two", "number": "2"]),
            3: Node(attributes: ["name":"three", "number": "3"]),

            10: Node(attributes: ["name":"ten", "number": "10"]),
            11: Node(attributes: ["name":"eleven", "number": "11"]),
            20: Node(attributes: ["name":"twenty", "number": "20"]),

            100: Node(attributes: ["name":"hundred", "number": "100"]),
            101: Node(attributes: ["name":"hundredone", "number": "101"]),
        ]

        
        for item in nodes {
            graph.add(item.value)
        }

        outlineNode = Node()
        graph.add(outlineNode)

        graph.connect(from: outlineNode, to: nodes[1]!,
                      attributes: ["label":"child", "index": 0])
        graph.connect(from: outlineNode, to: nodes[2]!,
                      attributes: ["label":"child", "index": 1])
        graph.connect(from: outlineNode, to: nodes[3]!,
                      attributes: ["label":"child", "index": 2])

        // Connect the 1-10-100 hierarchy
        graph.connect(from: nodes[1]!, to: nodes[10]!,
                      attributes: ["label":"child", "index": 0])
        graph.connect(from: nodes[1]!, to: nodes[1]!,
                      attributes: ["label":"child", "index": 1])

        graph.connect(from: nodes[10]!, to: nodes[100]!,
                      attributes: ["label":"child", "index": 0])
        graph.connect(from: nodes[10]!, to: nodes[101]!,
                      attributes: ["label":"child", "index": 1])

        // Connect the 2-20 hierarchy
        graph.connect(from: nodes[2]!, to: nodes[20]!,
                      attributes: ["label":"child", "index": 0])
        
        self.nodes = nodes

    }

    func testEmpty() {
        let node = Node()
        graph.add(node)
        let outline = OutlineCell(node)
        
        XCTAssertEqual(outline.children.count, 0)
        XCTAssertNil(outline.parent)
    }

    func testChildren() {
        let outline = OutlineCell(outlineNode)
        
        XCTAssertEqual(outline.children.count, 3)
        XCTAssertEqual(outline.children.nodes, [nodes[1]!, nodes[2]!, nodes[3]!])
    }
}
