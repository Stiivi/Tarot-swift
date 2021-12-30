//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/24.
//

import Foundation
import XCTest
@testable import Metamodel
@testable import GraphMemory

final class TraitsTests: XCTestCase {
    func testTrait() throws {
        let graph = GraphMemory()

        let ld = LinkDescription("cards", "card")
        let trait = Trait(name: "Stack", links: [ld])

        let c1 = Thing("Card 1")
        let c2 = Thing("Card 2")
        let c3 = Thing("Card 3")
        
        graph.add(c1)
        graph.add(c2)
        graph.add(c3)

        let stack = Thing("Stack")

        graph.add(stack)
        stack.trait = trait

        graph.connect(from: stack, to: c1, at: "card")
        graph.connect(from: stack, to: c2, at: "card")
        graph.connect(from: stack, to: c3, at: "card")

        XCTAssertEqual(Set(stack.related("cards")), Set([c1, c2, c3]))
        
        let cards = stack.related("cards")
        XCTAssertEqual(cards.count, 3)
    }
    
    func testReverseTrait() throws {
        let graph = GraphMemory()

        let ld = LinkDescription("colors", "component", isReverse:true)
        let trait = Trait(name: "Thing", links: [ld])

        let red = Thing("red")
        graph.add(red)
        red.trait = trait

        let green = Thing("green")
        graph.add(green)
        green.trait = trait

        let blue = Thing("blue")
        graph.add(blue)
        blue.trait = trait

        let yellow = Thing("yellow")
        graph.add(yellow)
        yellow.trait = trait

        let white = Thing("white")
        graph.add(white)
        white.trait = trait

        graph.connect(from: white, to: red, at: "component")
        graph.connect(from: white, to: green, at: "component")
        graph.connect(from: white, to: blue, at: "component")
        graph.connect(from: yellow, to: red, at: "component")
        graph.connect(from: yellow, to: green, at: "component")

        var colors: [Node] = []
        
        colors = white.related("colors")
        XCTAssertEqual(colors.count, 0)

        colors = red.related("colors")
        XCTAssertEqual(colors.count, 2)

        colors = green.related("colors")
        XCTAssertEqual(colors.count, 2)

        colors = blue.related("colors")
        XCTAssertEqual(colors.count, 1)
    }

}
