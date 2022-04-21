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
        let data: [Int:AttributeDictionary] = [
            1: ["name":"one", "number": "1"],
            2: ["name":"two", "number": "2"],
            3: ["name":"three", "number": "3"],

            10: ["name":"ten", "number": "10"],
            11: ["name":"eleven", "number": "11"],
            20: ["name":"twenty", "number": "20"],

            100: ["name":"hundred", "number": "100"],
            101: ["name":"hundredone", "number": "101"],
        ]

        nodes = [:]
        for item in data {
            nodes[item.key] = graph.create(attributes: item.value)
        }

        outlineNode = graph.create()

        graph.connect(from: outlineNode, to: nodes[1]!,
                      labels: ["child"],
                      attributes: ["index": 0])
        graph.connect(from: outlineNode, to: nodes[2]!,
                      labels: ["child"],
                      attributes: ["index": 1])
        graph.connect(from: outlineNode, to: nodes[3]!,
                      labels: ["child"],
                      attributes: ["index": 2])

        // Connect the 1-10-100 hierarchy
        graph.connect(from: nodes[1]!, to: nodes[10]!,
                      labels: ["child"],
                      attributes: ["index": 0])
        graph.connect(from: nodes[1]!, to: nodes[1]!,
                      labels: ["child"],
                      attributes: ["index": 1])

        graph.connect(from: nodes[10]!, to: nodes[100]!,
                      labels: ["child"],
                      attributes: ["index": 0])
        graph.connect(from: nodes[10]!, to: nodes[101]!,
                      labels: ["child"],
                      attributes: ["index": 1])

        // Connect the 2-20 hierarchy
        graph.connect(from: nodes[2]!, to: nodes[20]!,
                      attributes: ["index": 0])
    }

    func testEmpty() {
        let node = graph.create()
        let outline = OutlineCell(node)
        
        XCTAssertEqual(outline.children.count, 0)
        XCTAssertNil(outline.parent)
    }

    func testChildren() {
        let outline = OutlineCell(outlineNode)
        
        XCTAssertEqual(outline.children.count, 3)
        let childNodes = outline.children.map { $0.representedNode }
        XCTAssertEqual(childNodes, [nodes[1]!, nodes[2]!, nodes[3]!])
    }
}
