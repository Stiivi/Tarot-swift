//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 27/01/2022.
//

import XCTest

@testable import TarotKit


final class DotFormatterTests: XCTestCase {
    func testHeader() throws {
        let formatter = DotFormatter(name: "output")
        
        XCTAssertEqual(formatter.header(), "digraph output {\n")
    }
                       
    func testFooter() throws {
        let formatter = DotFormatter(name: "output")

        XCTAssertEqual(formatter.footer(), "}\n")
    }
    
    func testNode() throws {
        let formatter = DotFormatter()
        
        XCTAssertEqual(formatter.node("10"),
                       "    10;\n")
    }
    func testQuotedNode() throws {
        let formatter = DotFormatter()
        
        XCTAssertEqual(formatter.node("my node"),
                       "    \"my node\";\n")
    }
    func testAttributedNode() throws {
        let formatter = DotFormatter()
        let attrs = ["label": "Thing"]
        
        XCTAssertEqual(formatter.node("10", attributes: attrs),
                       "    10[label=Thing];\n")
    }
    func testQuoteAttributedNode() throws {
        let formatter = DotFormatter()
        
        XCTAssertEqual(formatter.node("10", attributes: ["label": "My Thing"]),
                       "    10[label=\"My Thing\"];\n")

        XCTAssertEqual(formatter.node("10", attributes: ["label": "\"Quoted\""]),
                       "    10[label=\"\\\"Quoted\\\"\"];\n")
    }
    func testEdge() throws {
        let formatter = DotFormatter()
        
        XCTAssertEqual(formatter.edge(from: "A", to: "B"),
                       "    A -> B;\n")
    }

    func testEdgeQuote() throws {
        let formatter = DotFormatter()
        
        XCTAssertEqual(formatter.edge(from: "Node A", to: "Node B"),
                       "    \"Node A\" -> \"Node B\";\n")
    }

    func testEdgeAttributes() throws {
        let formatter = DotFormatter()
        
        XCTAssertEqual(formatter.edge(from: "A", to: "B", attributes:  ["label": "Thing"]),
                       "    A -> B[label=Thing];\n")
    }

}
