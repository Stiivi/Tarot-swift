//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 20/02/2022.
//

import Foundation
import XCTest
@testable import TarotKit
@testable import Records

final class ObjectSelectionTests: XCTestCase {
    var graph: Graph!
    
    override func setUp() {
        graph = Graph()
    }
    
    func testSetSelectionObjects() {
        let selection = ObjectSelection(graph: graph)
        
        let node = Node()
        var observed = false
        
        graph.add(node)
        
        let observer = selection.observe().sink {
            observed = true
        }
        
        XCTAssertFalse(observed)
        selection.objects = [node]
        XCTAssertTrue(observed)
        observer.cancel()
    }
    
    func testAttributeChange() {
        let selection = ObjectSelection(graph: graph)
        
        let node = Node()
        var key: String? = nil
        var value: Value? = nil
        
        graph.add(node)
        
        let observer = selection.observeAttributes().sink {
            switch $0 {
            case let .setAttribute(_, ckey, cvalue):
                value = cvalue
                key = ckey
            case let .unsetAttribute(_, ckey):
                key = ckey
                value = nil
            default:
                key = nil
                value = nil
            }
        }
        
        selection.objects = [node]

        node["text"] = .string("test")
        XCTAssertEqual(key, "text")
        XCTAssertEqual(value, .string("test"))
        
        let node2 = Node()
        graph.add(node2)

        // Just sanity check
        node2["ignore"] = .string("yes")
        XCTAssertEqual(key, "text")
        XCTAssertEqual(value, .string("test"))

        selection.objects = [node2]
        node2["text two"] = .string("test two")
        XCTAssertEqual(key, "text two")
        XCTAssertEqual(value, .string("test two"))
        
        observer.cancel()
    }
}
