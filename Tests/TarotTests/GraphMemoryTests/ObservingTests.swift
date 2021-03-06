//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 26/01/2022.
//

import Foundation
import XCTest
@testable import TarotKit


final class GraphObservingTests: XCTestCase {
    var graph: Graph!
    
    override func setUp() {
        graph = Graph()
    }

    // TODO: Split it to different actions
    func testBasic() throws {
        let publisher = graph.observe()
        var lastChange: GraphChange? = nil
        
        let cancellable = publisher.sink {
            lastChange = $0
        }
        
        var node = graph.create()
        XCTAssertEqual(lastChange, .addNode(node))
        graph.remove(node)
        XCTAssertEqual(lastChange, .removeNode(node))

        let other = graph.create()
        node = graph.create()
        let link = graph.connect(from: node, to: other)
        XCTAssertEqual(lastChange, .connect(link))

        graph.disconnect(link: link)
        XCTAssertEqual(lastChange, .disconnect(link))

        node["name"] = .string("thing")
        XCTAssertEqual(lastChange, .setAttribute(node, "name", .string("thing")))

        node["name"] = nil
        XCTAssertEqual(lastChange, .unsetAttribute(node, "name"))

        cancellable.cancel()
    }
}
