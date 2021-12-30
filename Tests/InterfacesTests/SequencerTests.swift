//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 29/12/2021.
//

import XCTest
@testable import GraphMemory
@testable import Interface
@testable import Query

final class SequencerTests: XCTestCase {
    var graph: GraphMemory!
    
    override func setUp() {
        graph = GraphMemory()
        let nodes = [
            Node(attributes: ["name":"one", "number": "10"]),
            Node(attributes: ["name":"two", "number": "20"]),
            Node(attributes: ["name":"three", "number": "30"]),
            Node(attributes: ["name":"a"]),
            Node(attributes: ["name":"b"]),
            Node(attributes: ["name":"c"]),
            Node(attributes: ["name":"number"]),
            Node(attributes: ["name":"letter"]),
        ]
        for node in nodes {
            graph.add(node)
        }
    }
    func testBasic() throws {
        let sequencer = Sequencer(memory: graph)
        let desc = SequenceDescription(
            predicate: AttributeValuePredicate(key: "", value: ""),
            targetAttributes: [:]
        )
        
    }
}
