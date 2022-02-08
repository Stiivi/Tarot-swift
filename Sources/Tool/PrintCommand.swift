//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 08/02/2022.
//

import Foundation
import TarotKit
import ArgumentParser

extension Tarot {
    struct Print: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Print nodes and their attributes")
        @OptionGroup var options: Options

        @Flag(name: [.customLong("incoming")],
              help: "Include incoming links.")
        var includeIncoming = false

        @Flag(name: [.customLong("outgoing")],
              help: "Include outgoing links.")
        var includeOutgoing = false

        
        @Argument(help: "IDs of nodes to be printed")
        var references: [String]

        mutating func run() {
            let manager = createManager(options: options)
            
            for reference in references {
                guard let id = OID(reference) else {
                    print("Invalid ID format: \(reference)")
                    continue
                }
                guard let object: Object = manager.graph.node(id) ?? manager.graph.link(id) else {
                    print("Unknown object ID: \(reference)")
                    continue
                }

                prettyPrintObject(object, indent: 0)

                if let node = object as? Node {
                    prettyPrintLinks(node)
                }
                print()
            }
        }

        func prettyPrintLinks(_ node: Node) {
            if includeOutgoing {
                let outgoing = node.outgoing
                if outgoing.count == 0 {
                    print("    (no outgoing links)")
                }
                else {
                    for link in outgoing {
                        let label = " target \(link.target.id!)"
                        prettyPrintObject(link, label: label, indent: 4)
                    }
                }
            }
            
            if includeIncoming {
                let incoming = node.incoming
                if incoming.count == 0 {
                    print("    (no incoming links)")
                }
                else {
                    for link in incoming {
                        let label = " origin \(link.target.id!)"
                        prettyPrintObject(link, label: label, indent: 4)
                    }
                }
            }
        }
        
        /// Pretty print object
        func prettyPrintObject(_ object: Object, label: String="", indent: Int=0) {
            // Sort attributes alphabetically
            let attrs = object.attributes.keys.sorted()
            let type: String
            let maxLength = attrs.map { $0.count }.max() ?? 0
            let indentString = String(repeating: " ", count: indent)

            switch object {
            case is Link: type = "Link"
            case is Node: type = "Node"
            default: type = "Unknown Object"
            }
            print("\(indentString)\(type) \(object.id!)\(label)")
            
            if attrs.count == 0 {
                print("\(indentString)    (no attributes)")
            }
            else {
                for attr in attrs {
                    let value = object[attr]?.stringValue() ?? "(nil)"
                    let padding = String(repeating: " ", count: maxLength - attr.count)
                    print("\(indentString)    \(attr)\(padding): \(value)")
                }
            }
        }
    }
}

