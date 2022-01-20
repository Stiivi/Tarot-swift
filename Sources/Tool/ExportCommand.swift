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
        var output: String

        @Argument(help: "Named node to be exported")
        var nodeName: String
        
        // Design notes:
        //
        // tarot extract Card
        //
        mutating func run() throws {
            let manager = createManager(options: options)
            guard let catalog = manager.catalog else {
                fatalError("No catalog found in the store.")
            }

            guard let testURL = URL(string: output) else {
                fatalError("Invalid resource reference: \(output)")
            }
            let outputURL: URL

            if testURL.scheme == nil {
                outputURL = URL(fileURLWithPath: output)
            }
            else {
                outputURL = testURL
            }

            guard let node = catalog.node(forKey: .string(nodeName)) else {
                fatalError("No named node: \(nodeName)")
            }
            print("Exporting node named: \(nodeName)")

            let exporter: Exporter
            
            switch format {
            case "md":
                exporter = MarkdownExporter()
            case "markdown":
                exporter = MarkdownExporter()
            default:
                fatalError("Unknown input format: \(format)")
            }

            try exporter.export(node: node, into: outputURL)
        }
    }
}
