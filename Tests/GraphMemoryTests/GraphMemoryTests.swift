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

        graph.associate(a)
        XCTAssertTrue(graph.contains(node: a))
        XCTAssertFalse(graph.contains(node: b))

        graph.associate(b)
        XCTAssertTrue(graph.contains(node: b))
    }
    func testConnect() throws {

        let space = GraphMemory()
        let a = Thing("Node A")

        space.associate(a)
        let b = Thing("Node B")
        space.associate(b)

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

        space.associate(a)
        space.associate(b)

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
        space.associate(a)
        space.remove(node: a)

        XCTAssertEqual(space.nodes.count, 0)
    }
    func testOutgoingIncoming() throws {
        let space = GraphMemory()
        let a = Thing("Node A")
        let b = Thing("Node B")
        let c = Thing("Node C")
        space.associate(a)
        space.associate(b)
        space.associate(c)

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

        space.associate(a)
        space.associate(b)
        space.connect(from: a, to: b, at: "next")

        space.remove(node: a)
        XCTAssertEqual(space.links.count, 0)
    }

    func testTrait() throws {
        let graph = GraphMemory()

        let ld = LinkTrait("cards", "card")
        let trait = Trait(name: "Stack", links: [ld])

        let c1 = Thing("Card 1")
        let c2 = Thing("Card 2")
        let c3 = Thing("Card 3")
        
        graph.associate(c1)
        graph.associate(c2)
        graph.associate(c3)

        let stack = Thing("Stack")

        graph.associate(stack)
        stack.trait = trait

        graph.connect(from: stack, to: c1, at: "card")
        graph.connect(from: stack, to: c2, at: "card")
        graph.connect(from: stack, to: c3, at: "card")

        let cards = stack.cards
        XCTAssertEqual(cards!.count, 3)
    }
    
    func testReverseTrait() throws {
        let graph = GraphMemory()

        let ld = LinkTrait("colors", "component", isReverse:true)
        let trait = Trait(name: "Thing", links: [ld])

        let red = Thing("red")
        graph.associate(red)
        red.trait = trait

        let green = Thing("green")
        graph.associate(green)
        green.trait = trait

        let blue = Thing("blue")
        graph.associate(blue)
        blue.trait = trait

        let yellow = Thing("yellow")
        graph.associate(yellow)
        yellow.trait = trait

        let white = Thing("white")
        graph.associate(white)
        white.trait = trait

        graph.connect(from: white, to: red, at: "component")
        graph.connect(from: white, to: green, at: "component")
        graph.connect(from: white, to: blue, at: "component")
        graph.connect(from: yellow, to: red, at: "component")
        graph.connect(from: yellow, to: green, at: "component")

        var colors: [Node] = []
        
        colors = white.colors!
        XCTAssertEqual(colors.count, 0)

        colors = red.colors!
        XCTAssertEqual(colors.count, 2)

        colors = green.colors!
        XCTAssertEqual(colors.count, 2)

        colors = blue.colors!
        XCTAssertEqual(colors.count, 1)
    }


}

