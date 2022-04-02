//
//  ChangeUndoRecorderTests.swift
//  
//
//  Created by Stefan Urbanek on 23/02/2022.
//

import Foundation
import XCTest
@testable import TarotKit
@testable import Records

final class ChangeUndoRecorderTests: XCTestCase {
    var graph: Graph!
    
    override func setUp() {
        graph = Graph()
    }
    
    func testAddNode() {
        let node = Node()
        let recorder = ReversibleChangeRecorder(graph: graph)

        let changes = recorder.record {
            graph.add(node)
        }
        
        XCTAssertEqual(changes.count, 1)
        XCTAssertEqual(changes[0], .removeNode(node))
    }
    
    func testRemoveNode() {
        let node = Node()
        let recorder = ReversibleChangeRecorder(graph: graph)
        
        graph.add(node)
        let link = graph.connect(from: node, to: node)
        
        let changes = recorder.record {
            graph.remove(node)
        }
        
        XCTAssertEqual(changes.count, 2)
        XCTAssertEqual(changes[0], .addNode(node))
        XCTAssertEqual(changes[1], .connect(link))
    }
    
    func testAddAndChange() {
        let node = Node()
        let recorder = ReversibleChangeRecorder(graph: graph)
        
        let changes = recorder.record {
            graph.add(node)
            node["text"] = .string("test")
        }
        
        XCTAssertEqual(changes.count, 2)
        XCTAssertEqual(changes[0], .unsetAttribute(node, "text"))
        XCTAssertEqual(changes[1], .removeNode(node))
    }

    func testIndexedCollectionAppend() {
        let collectionNode = Node()
        let collection = IndexedNeighbourhood(collectionNode,
                                           selector:LinkSelector("item"),
                                           indexAttribute: "index")
        let node = Node()
        
        graph.add(collectionNode)
        graph.add(node)

        let recorder = ReversibleChangeRecorder(graph: graph)
        let changes = recorder.record {
            collection.append(node)
        }

        XCTAssertEqual(graph.links.count, 1)

        for change in changes {
            graph.applyChange(change)
        }
        
        XCTAssertEqual(graph.links.count, 0)
        XCTAssertEqual(graph.nodes.count, 2 )
    }
    
    func testIndexedCollectionRemoveCorrupted() {
        let collectionNode = Node()
        let collection = IndexedNeighbourhood(collectionNode,
                                           selector:LinkSelector("item"),
                                           indexAttribute: "index")
        let node = Node()

        graph.add(collectionNode)
        graph.add(node)

        let recorder = ReversibleChangeRecorder(graph: graph)

        let link = collection.append(node)

        // Create another item with the same index
        graph.connect(from: collectionNode, to: node, attributes: [
            "label": "item",
            "comment": "corrupted link",
            "index": link["index"]!
        ])

        let changes = recorder.record {
            collection.remove(node)
        }
        
        XCTAssertEqual(graph.links.count, 0)

        for change in changes {
            graph.applyChange(change)
        }
        
        XCTAssertEqual(graph.links.count, 2)
    }
}
