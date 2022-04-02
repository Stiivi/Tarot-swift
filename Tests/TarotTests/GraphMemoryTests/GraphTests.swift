import XCTest
@testable import TarotKit


final class GraphTests: XCTestCase {
    func testAdd() throws {
        let graph = Graph()

        let a = graph.create()
        XCTAssertTrue(graph.contains(node: a))

        let b = graph.create()
        XCTAssertTrue(graph.contains(node: b))
    }
    func testConnect() throws {

        let graph = Graph()
        let a = graph.create()
        let b = graph.create()

        let link = graph.connect(from: a, to: b)

        XCTAssertEqual(graph.links.count, 1)
        XCTAssertIdentical(link.graph, graph)
        XCTAssertIdentical(link.origin, a)
        XCTAssertIdentical(link.target, b)
    }
    
    func testRemoveConnection() throws {
        let graph = Graph()
        let a = graph.create()
        let b = graph.create()
        var link: Link

        link = graph.connect(from: a, to: b)
        XCTAssertEqual(graph.links.count, 1)
        graph.disconnect(link: link)
        XCTAssertEqual(graph.links.count, 0)
    }

    func testRemoveNode() throws {
        let graph = Graph()
        let a = graph.create()

        graph.remove(a)

        XCTAssertEqual(graph.nodes.count, 0)
    }

    func testOutgoingIncoming() throws {
        let graph = Graph()
        let a = graph.create()
        let b = graph.create()
        let c = graph.create()

        graph.connect(from: a, to: b, attributes: ["name": "child"])
        graph.connect(from: a, to: c, attributes: ["name": "child"])

        XCTAssertEqual(graph.outgoing(a).count, 2)
        XCTAssertEqual(graph.outgoing(b).count, 0)
        XCTAssertEqual(graph.outgoing(c).count, 0)

        XCTAssertEqual(graph.incoming(a).count, 0)
        XCTAssertEqual(graph.incoming(b).count, 1)
        XCTAssertEqual(graph.incoming(c).count, 1)

        let links = graph.outgoing(a)
        XCTAssertEqual(links[0]["name"], "child")
        XCTAssertEqual(links[1]["name"], "child")
    }

    func testRemoveConnected() throws {
        let graph = Graph()
        let a = graph.create()
        let b = graph.create()

        graph.connect(from: a, to: b)

        graph.remove(a)
        XCTAssertEqual(graph.links.count, 0)
    }
}
