//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/27.
//

import Foundation
import XCTest
@testable import GraphMemory

final class QueryTests: XCTestCase {
    var graph: GraphMemory?
    override func setUp() {
        graph = GraphMemory()
        let nodes = [
            Node(attributes: ["name":"one", "number": "10"]),
            Node(attributes: ["name":"two", "number": "20"]),
            Node(attributes: ["name":"three", "number": "30"]),
        ]
    }
    func testBasic() throws {
        let graph = self.graph!
        // let predicate = TextBeginsWith("t")
        // let query = Query([predicate])
    }
}
