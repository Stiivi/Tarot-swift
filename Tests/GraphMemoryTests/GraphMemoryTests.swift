import XCTest
@testable import GraphMemory

class Thing: Node {
    let label: String
    
    init(_ label: String) {
        self.label = label
    }
}

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

        let space = GraphMemory()
        let a = Thing("Node A")

        space.add(a)
        let b = Thing("Node B")
        space.add(b)

        space.connect(from: a, to: b, at: "next")

        XCTAssertEqual(space.links.count, 1)
        
        let link = space.links.first!

        XCTAssertIdentical(link.origin, a)
        XCTAssertIdentical(link.target, b)
        XCTAssertEqual(link.name, "next")
    }
    func testDisconnect() throws {
        let space = GraphMemory()
        let a = Thing("Node A")
        let b = Thing("Node B")

        space.add(a)
        space.add(b)

        space.connect(from: a, to: b, at: "next")
        XCTAssertEqual(space.links.count, 1)
        space.disconnect(from: a, to: b, at: "next")
        XCTAssertEqual(space.links.count, 0)

        // Test whether multiple connections are removed
        space.connect(from: a, to: b, at: "next")
        space.connect(from: a, to: b, at: "next")
        space.connect(from: a, to: b, at: "next")

        XCTAssertEqual(space.links.count, 3)
        space.disconnect(from: a, to: b, at: "next")
        XCTAssertEqual(space.links.count, 0)
    }

    func testRemove() throws {
        let space = GraphMemory()
        let a = Thing("Node A")
        space.add(a)
        space.remove(node: a)

        XCTAssertEqual(space.nodes.count, 0)
    }
    func testOutgoingIncoming() throws {
        let space = GraphMemory()
        let a = Thing("Node A")
        let b = Thing("Node B")
        let c = Thing("Node C")
        space.add(a)
        space.add(b)
        space.add(c)

        space.connect(from: a, to: b, at: "child")
        space.connect(from: a, to: c, at: "child")

        XCTAssertEqual(space.outgoing(a).count, 2)
        XCTAssertEqual(space.outgoing(b).count, 0)
        XCTAssertEqual(space.outgoing(c).count, 0)

        XCTAssertEqual(space.incoming(a).count, 0)
        XCTAssertEqual(space.incoming(b).count, 1)
        XCTAssertEqual(space.incoming(c).count, 1)

        let links = space.outgoing(a)
        XCTAssertEqual(links[0].name, "child")
        XCTAssertEqual(links[1].name, "child")
    }

    func testRemoveConnected() throws {
        let space = GraphMemory()
        let a = Thing("Node A")
        let b = Thing("Node B")

        space.add(a)
        space.add(b)
        space.connect(from: a, to: b, at: "next")

        space.remove(node: a)
        XCTAssertEqual(space.links.count, 0)
    }
}
