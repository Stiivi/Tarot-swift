//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//

import Foundation
import TarotKit
import ArgumentParser

extension Tarot {
    struct  Export: ParsableCommand {
        static var configuration
            = CommandConfiguration(
                abstract: "Export objects",
                discussion: """
Exports the nodes and links into a file or another structure.
                        
Available formats: markdown.
""")

        @OptionGroup var options: Options

        @Option(name: [.long, .customShort("f")],
                help: "Format")
        var format: String = "auto"

        @Option(name: [.long, .customShort("o")],
                help: "Output path or URL")
        var output: String?

        @Argument(help: "Named collection to be exported")
        var collection: String
        
        // Design notes:
        //
        // tarot extract Card
        //
        mutating func run() {
            let space = openSpace(options: options)

            let nodes: [Node]
            print("Hello from export")
//            if let traitName = traitName {
//                nodes = space.memory.filter(traitName: traitName)
//            }
//            else {
//                nodes = Array(space.memory.nodes)
//            }
//
//            let encoder = JSONEncoder()
//            for node in nodes {
//                // FIXME: Implement this
//                fatalError("Not implemented")
//                // let dict = node.asDictionary()
//                // let data = try encoder.encode(dict)
//            }
        }
    }
}
