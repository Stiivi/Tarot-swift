//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/04/2022.
//

import Foundation
import XCTest
@testable import TarotKit
@testable import Records

final class NeighbourhoodTraitTest: XCTestCase {
    var graph: Graph!
    
    override func setUp() {
        graph = Graph()
    }
    
    func testHoodTrait() {
        let trait = Trait(graph.create())
        let hoodTrait = NeighbourhoodTrait(graph.create())
        hoodTrait.type = .indexed
        
        trait.neighbourhoods["related"] = hoodTrait.representedNode
        
        let card = graph.create()
        card.setTrait(trait)
        
        XCTAssertNil(card.neighbourhood("unknown"))
        XCTAssertNotNil(card.neighbourhood("related") as? IndexedNeighbourhood)

        XCTAssertEqual(card.trait, trait)
    }
}
