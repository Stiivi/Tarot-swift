//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 08/02/2022.
//

import Records
import Foundation
import ArgumentParser
import TarotKit

// MARK: Set attribute

extension Tarot {
    struct SetAttribute: ParsableCommand {
        static var configuration
            = CommandConfiguration(
                commandName: "set",
                abstract: "Set or unset attribute value"
            )
        @OptionGroup var options: Options

//        @Option(name: [.long, .customShort("t")],
//                help: "Data Type")
//        var type: String
        
        @Argument(help: "ID of a node or a link to be modified")
        var reference: String

        @Argument(help: "Attribute to be set/unset")
        var attribute: String

        @Argument(help: "Attribute value. If not provided, attribute will be unset")
        var valueString: String?

        mutating func run() throws {
            let manager = createManager(options: options)

            guard let id = OID(reference) else {
                print("Invalid ID format: \(reference)")
                return
            }
            guard let object: Object = manager.graph.node(id) ?? manager.graph.link(id) else {
                print("Unknown object ID: \(reference)")
                return
            }
            
            // TODO: Convert to appropriate type
            if let string = valueString {
                let value:Value = .string(string)
                object[attribute] = value
            }
            else {
                object[attribute] = nil
            }
            
            try finalizeManager(manager: manager, options: options)
        }
    }
}

// MARK: Create Node

extension Tarot {
    struct CreateNode: ParsableCommand {
        static var configuration
            = CommandConfiguration(
                commandName: "create",
                abstract: "Create new node"
            )
        @OptionGroup var options: Options

        mutating func run() throws {
            let manager = createManager(options: options)

            let node = manager.graph.create()
            print(node.id!)
            
            try finalizeManager(manager: manager, options: options)
        }
    }
}

extension Tarot {
    struct Remove: ParsableCommand {
        static var configuration
            = CommandConfiguration(
                commandName: "remove",
                abstract: "Remove nodes or links"
            )
        @OptionGroup var options: Options

        @Argument(help: "IDs of nodes or links to be removed")
        var references: [String]

        mutating func run() throws {
            let manager = createManager(options: options)

            for reference in references {
                guard let id = OID(reference) else {
                    print("Invalid ID format: \(reference)")
                    continue
                }

                if let node = manager.graph.node(id) {
                    manager.graph.remove(node)
                }
                else if let link = manager.graph.link(id) {
                    manager.graph.disconnect(link: link)
                }
                else {
                    print("Unknown node or a link with ID: \(id)")
                }
            }

            try finalizeManager(manager: manager, options: options)
        }
    }
}


extension Tarot {
    struct Connect: ParsableCommand {
        static var configuration
            = CommandConfiguration(
                commandName: "connect",
                abstract: "Connects a node to one or more nodes, prints link IDs"
            )
        @OptionGroup var options: Options

        @Flag(name: [.customLong("reverse")],
              help: "Create reverse links - from \"target\" to \"origin\"")
        var reverse = false

        
        @Argument(help: "ID of origin node")
        var originReference: String

        @Argument(help: "IDs of target nodes")
        var targetReferences: [String]

        mutating func run() throws {
            let manager = createManager(options: options)

            guard let originId = OID(originReference) else {
                print("Invalid ID format for origin: \(originReference)")
                return
            }
            
            guard let origin = manager.graph.node(originId) else {
                print("Unknown node with ID: \(originId)")
                return
            }

            var links: [Link] = []
            
            for reference in targetReferences {
                guard let id = OID(reference) else {
                    print("Invalid ID format: \(reference)")
                    continue
                }
                
                guard let target = manager.graph.node(id) else {
                    print("Unknown node with ID: \(id)")
                    continue
                }

                let link: Link
                if reverse {
                    link = manager.graph.connect(from: target, to: origin)
                }
                else {
                    link = manager.graph.connect(from: origin, to: target)
                }
                
                links.append(link)
            }

            for link in links {
                print(link.id!)
            }
            
            try finalizeManager(manager: manager, options: options)
        }
    }
}

