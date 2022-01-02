import XCTest
@testable import TarotKit


final class GraphMemoryTests: XCTestCase {
    func testAdd() throws {
        let graph = GraphMemory()
        let a = Thing("Node A")
        let b = Thing("Node B")

        graph.add(a)
        XCTAssertTrue(graph.contains(node: a))
        XCTAssertFalse(graph.contains(node: b))

        graph.add(b)
        XCTAssertTrue(graph.contains(node: b))
    }
    func testConnect() throws {

        let memory = GraphMemory()
        let a = Thing("Node A")

        memory.add(a)
        let b = Thing("Node B")
        memory.add(b)

        let link = memory.connect(from: a, to: b)

        XCTAssertEqual(memory.links.count, 1)
        XCTAssertIdentical(link.graph, memory)
        XCTAssertIdentical(link.origin, a)
        XCTAssertIdentical(link.target, b)
    }
    
    // Note: See comment in the commented-out GraphMemory.disconnect() code
    // why we are not using it for now.
    //
//    func testDisconnect() throws {
//        let memory = GraphMemory()
//        let a = Thing("Node A")
//        let b = Thing("Node B")
//
//        memory.add(a)
//        memory.add(b)
//
//        memory.connect(from: a, to: b, at: "next")
//        XCTAssertEqual(memory.links.count, 1)
//        memory.disconnect(from: a, to: b, at: "next")
//        XCTAssertEqual(memory.links.count, 0)
//
//        // Test whether multiple connections are removed
//        memory.connect(from: a, to: b, at: "next")
//        memory.connect(from: a, to: b, at: "next")
//        memory.connect(from: a, to: b, at: "next")
//
//        XCTAssertEqual(memory.links.count, 3)
//        memory.disconnect(from: a, to: b, at: "next")
//        XCTAssertEqual(memory.links.count, 0)
//    }
    func testRemoveConnection() throws {
        let memory = GraphMemory()
        let a = Thing("Node A")
        let b = Thing("Node B")
        var link: Link

        memory.add(a)
        memory.add(b)

        link = memory.connect(from: a, to: b)
        XCTAssertEqual(memory.links.count, 1)
        memory.disconnect(link: link)
        XCTAssertEqual(memory.links.count, 0)
    }

    func testRemoveNode() throws {
        let memory = GraphMemory()
        let a = Thing("Node A")
        memory.add(a)
        memory.remove(a)

        XCTAssertEqual(memory.nodes.count, 0)
    }

    func testOutgoingIncoming() throws {
        let memory = GraphMemory()
        let a = Thing("Node A")
        let b = Thing("Node B")
        let c = Thing("Node C")
        memory.add(a)
        memory.add(b)
        memory.add(c)

        memory.connect(from: a, to: b, attributes: ["name": "child"])
        memory.connect(from: a, to: c, attributes: ["name": "child"])

        XCTAssertEqual(memory.outgoing(a).count, 2)
        XCTAssertEqual(memory.outgoing(b).count, 0)
        XCTAssertEqual(memory.outgoing(c).count, 0)

        XCTAssertEqual(memory.incoming(a).count, 0)
        XCTAssertEqual(memory.incoming(b).count, 1)
        XCTAssertEqual(memory.incoming(c).count, 1)

        let links = memory.outgoing(a)
        XCTAssertEqual(links[0]["name"], "child")
        XCTAssertEqual(links[1]["name"], "child")
    }

    func testRemoveConnected() throws {
        let memory = GraphMemory()
        let a = Thing("Node A")
        let b = Thing("Node B")

        memory.add(a)
        memory.add(b)
        memory.connect(from: a, to: b)

        memory.remove(a)
        XCTAssertEqual(memory.links.count, 0)
    }
}
