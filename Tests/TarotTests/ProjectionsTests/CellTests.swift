//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 17/01/2022.
//

import Foundation
import XCTest
@testable import TarotKit

final class CellTests: XCTestCase {
    var graph: Graph!
    
    override func setUp() {
        graph = Graph()
    }
    
    func testBasic() {
        let contentNode = Node()
        let cellNode = Node()

        graph.add(contentNode)
        graph.add(cellNode)
        
        let cell = Cell(cellNode)
        XCTAssertNil(cell.content())
        
        graph.connect(from: cellNode,
                      to: contentNode,
                      attributes: ["label":"content"])

        XCTAssertIdentical(cell.content(), contentNode)
        XCTAssertEqual(cellNode.outgoing.count, 1)
    }
    
    func testSetContent() {
        let contentNode = Node()
        let newNode = Node()
        let cellNode = Node()

        graph.add(contentNode)
        graph.add(newNode)
        graph.add(cellNode)
        
        let cell = Cell(cellNode)

        cell.setContent(contentNode)
        XCTAssertIdentical(cell.content(), contentNode)
        XCTAssertEqual(cellNode.outgoing.count, 1)

        // Replace content
        cell.setContent(newNode)
        XCTAssertIdentical(cell.content(), newNode)
        XCTAssertEqual(cellNode.outgoing.count, 1)
    }
    
    func testRemoveContent() {
        let contentNode = Node()
        let cellNode = Node()

        graph.add(contentNode)
        graph.add(cellNode)
        
        let cell = Cell(cellNode)
        cell.setContent(contentNode)
        cell.removeContent()
        XCTAssertEqual(cellNode.outgoing.count, 0)
        XCTAssertNil(cell.content())
    }

    func testSetContentDeletesExisting() {
        let dummy = Node()
        let contentNode = Node()
        let cellNode = Node()

        graph.add(dummy)
        graph.add(contentNode)
        graph.add(cellNode)

        graph.connect(from: cellNode,
                      to: dummy,
                      attributes: ["label":"content"])
        graph.connect(from: cellNode,
                      to: dummy,
                      attributes: ["label":"content"])

        XCTAssertEqual(cellNode.outgoing.count, 2)

        let cell = Cell(cellNode)

        // We get one of the dummies
        XCTAssertIdentical(cell.content(), dummy)
        
        cell.setContent(contentNode)
        // Only the newly set content node will be connected
        XCTAssertEqual(cellNode.outgoing.count, 1)
        XCTAssertIdentical(cell.content(), contentNode)
    }
}