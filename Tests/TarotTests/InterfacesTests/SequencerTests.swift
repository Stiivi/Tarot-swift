//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 29/12/2021.
//

import XCTest
@testable import TarotKit

final class SequencerTests: XCTestCase {
    var graph: GraphMemory!
    
    override func setUp() {
        graph = GraphMemory()
        let nodes = [
            1: Node(attributes: ["name":"one", "number": "10"]),
            2: Node(attributes: ["name":"two", "number": "20"]),
            3: Node(attributes: ["name":"three", "number": "30"]),
            10: Node(attributes: ["name":"a"]),
            20: Node(attributes: ["name":"b"]),
            30: Node(attributes: ["name":"c"]),
            100: Node(attributes: ["name":"number"]),
            200: Node(attributes: ["name":"letter"]),
        ]
        for node in nodes.values {
            graph.add(node)
        }
        
        graph.connect(from:nodes[1]!, to:nodes[100]!, attributes: ["name": "type"])
        graph.connect(from:nodes[2]!, to:nodes[100]!, attributes: ["name": "type"])
        graph.connect(from:nodes[3]!, to:nodes[100]!, attributes: ["name": "type"])

        graph.connect(from:nodes[1]!, to:nodes[2]!, attributes: ["name": "next"])
        graph.connect(from:nodes[2]!, to:nodes[3]!, attributes: ["name": "next"])

        
        graph.connect(from:nodes[10]!, to:nodes[200]!, attributes: ["name": "type"])
        graph.connect(from:nodes[20]!, to:nodes[200]!, attributes: ["name": "type"])
        graph.connect(from:nodes[30]!, to:nodes[200]!, attributes: ["name": "type"])
        
        let model = Model(
            name: "test model",
            traits: [
                  Trait(name: "Type",
                        links: [
                          LinkDescription("instances", "type", isReverse:true)
                        ]),
                  Trait(name: "Thing",
                        links: [
                          LinkDescription("type", "type")
                        ])
                  ]
            )

    }
    func testBasic() throws {
        let sequencer = Sequencer(memory: graph)
        let desc = SequenceDescription(
            predicate: AttributeValuePredicate(key: "name", value: "number"),
            targetAttributes: [:]
        )
        
    }
}
