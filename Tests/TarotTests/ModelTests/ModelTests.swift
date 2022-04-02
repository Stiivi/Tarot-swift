//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/04/2022.
//

import Foundation

import XCTest
@testable import TarotKit
@testable import Records

final class ModelTests: XCTestCase {
    var graph: Graph!
    
    override func setUp() {
        graph = Graph()
    }
    
    func testAddTrait() {
        let model = Model(graph.create())
        let trait = Trait(graph.create())

        model.traits["Card"] = trait.representedNode
        
        XCTAssertIdentical(model.traits["Card"], trait.representedNode)
    }
    
    func testSetTrait() {
        let model = Model(graph.create())
        let trait = Trait(graph.create())

        model.traits["Card"] = trait.representedNode

        let card = graph.create()

        XCTAssertNil(card.trait)

        card.setTrait(trait)
        
        XCTAssertEqual(card.trait, trait)
    }

    func testTraitNodes() {
        let model = Model(graph.create())
        let trait = Trait(graph.create())

        model.traits["Card"] = trait.representedNode

        let node1 = graph.create()
        let node2 = graph.create()

        XCTAssertTrue(trait.nodes.isEmpty)

        node1.setTrait(trait)
        
        XCTAssertEqual(trait.nodes.count, 1)
        XCTAssertEqual(trait.nodes, [node1])

        node2.setTrait(trait)
        XCTAssertEqual(trait.nodes.count, 2)
        XCTAssertEqual(Set(trait.nodes), Set([node1, node2]))
        
        node1.removeTrait()
        XCTAssertEqual(trait.nodes.count, 1)
        XCTAssertEqual(trait.nodes, [node2])
    }
}

