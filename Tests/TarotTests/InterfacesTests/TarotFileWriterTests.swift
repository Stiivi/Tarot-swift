//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 19/01/2022.
//

import Foundation

import XCTest
@testable import TarotKit
@testable import Records

// Testing writer makes sense only when the loader can reliably load the
// writer's output.

final class TarotFileWriterTests: XCTestCase {
    var graph: Graph!
    var nodes: [Int:Node]!

    override func setUp() {
        self.graph = Graph()
        let nodeAttributes: [Int:AttributeDictionary] = [
            1: ["name": "one"],
            2: ["name": "two"],
            3: ["name": "three"],
        ]
        
        nodes = [:]
        for item in nodeAttributes {
            nodes[item.key] = graph.create(attributes: item.value)
        }
    }

    /**
    Creates a URL for a temporary file on disk. Registers a teardown block to
    delete a file at that URL (if one exists) during test teardown.
    */
    func temporaryFileURL() -> URL {
        
        // Create a URL for an unique file in the system's temporary directory.
        let directory = NSTemporaryDirectory()
        let filename = UUID().uuidString
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent(filename)
        
        // Add a teardown block to delete any file at `fileURL`.
        addTeardownBlock {
            do {
                let fileManager = FileManager.default
                // Check that the file exists before trying to delete it.
                if fileManager.fileExists(atPath: fileURL.path) {
                    // Perform the deletion.
                    try fileManager.removeItem(at: fileURL)
                    // Verify that the file no longer exists after the deletion.
                    XCTAssertFalse(fileManager.fileExists(atPath: fileURL.path))
                }
            } catch {
                // Treat any errors during file deletion as a test failure.
                XCTFail("Error while deleting temporary file: \(error)")
            }
        }
        
        // Return the temporary file URL for use in a test method.
        return fileURL
        
    }
    
    func testEmpty() throws {
        let url = temporaryFileURL()
        let writer = TarotFileWriter(url: url)
        let emptyGraph = Graph()
        let newGraph = Graph()
        let loader = TarotFileLoader(graph: newGraph)
        try writer.write(graph: emptyGraph)

        let _ = try loader.load(from: url, preserveIdentity: true)
        XCTAssertEqual(newGraph.nodes.count, 0)
        XCTAssertEqual(newGraph.links.count, 0)
    }

    func testNodes() throws {
        let url = temporaryFileURL()
        let writer = TarotFileWriter(url: url)
        let newGraph = Graph()
        let loader = TarotFileLoader(graph: newGraph)
        
        let names = [
            "one": nodes[1]!,
            "two": nodes[2]!,
            "three": nodes[3]!,
        ]
        
        try writer.write(graph: graph, names: names)

        let newNames = try loader.load(from: url, preserveIdentity: true)
        XCTAssertEqual(newGraph.nodes.count, 3)
        XCTAssertEqual(newGraph.links.count, 0)
        
        let one = newNames["one"]!
        let two = newNames["two"]!
        let three = newNames["three"]!

        XCTAssertEqual(one.id, nodes[1]!.id)
        XCTAssertEqual(two.id, nodes[2]!.id)
        XCTAssertEqual(three.id, nodes[3]!.id)

        XCTAssertEqual(one["name"], "one")
        XCTAssertEqual(two["name"], "two")
        XCTAssertEqual(three["name"], "three")
    }

    func testLinks() throws {
        let url = temporaryFileURL()
        let writer = TarotFileWriter(url: url)
        let newGraph = Graph()
        let loader = TarotFileLoader(graph: newGraph)
        
        graph.connect(from: nodes[1]!, to: nodes[2]!, attributes: ["label": "next"])
        graph.connect(from: nodes[2]!, to: nodes[3]!, attributes: ["label": "last"])

        let names = [
            "one": nodes[1]!,
            "two": nodes[2]!,
            "three": nodes[3]!,
        ]
        
        try writer.write(graph: graph, names: names)

        let newNames = try loader.load(from: url, preserveIdentity: true)
        XCTAssertEqual(newGraph.nodes.count, 3)
        XCTAssertEqual(newGraph.links.count, 2)
        
        let one = newNames["one"]!
        let two = newNames["two"]!
        let three = newNames["three"]!

        XCTAssertEqual(one.outgoing.count, 1)
        let linkOne = one.outgoing.first!
        XCTAssertIdentical(linkOne.origin, one)
        XCTAssertIdentical(linkOne.target, two)
        
        XCTAssertEqual(linkOne["label"]!, "next")

        XCTAssertEqual(two.outgoing.count, 1)
        let linkTwo = two.outgoing.first!
        XCTAssertIdentical(linkTwo.origin, two)
        XCTAssertIdentical(linkTwo.target, three)
        XCTAssertEqual(linkTwo["label"]!, "last")

        XCTAssertEqual(three.outgoing.count, 0)
    }

}
