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
    struct Extract: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Extract objects")

        @OptionGroup var options: Options

        @Option(name: [.long, .customShort("t")],
                help: "Trait name")
        var traitName: String?

        /// Extract objects into a JSON file.
        ///
        // Design notes:
        //
        // tarot extract Card
        //
        mutating func run() {
            let space = makeSpace(options: options)

            let nodes: [Node]
            
            if let traitName = traitName {
                nodes = space.memory.filter(traitName: traitName)
            }
            else {
                nodes = Array(space.memory.nodes)
            }
            
            let encoder = JSONEncoder()
            for node in nodes {
                // FIXME: Implement this
                fatalError("Not implemented")
                // let dict = node.asDictionary()
                // let data = try encoder.encode(dict)
            }
        }
    }
}
