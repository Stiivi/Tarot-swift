//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//
import Foundation
import TarotKit
import ArgumentParser



// The Command
// ------------------------------------------------------------------------

struct Tarot: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Tarot utility.",
        subcommands: [
            Create.self,
            Import.self,
            List.self,
            Export.self,
            Print.self,
            WriteDOT.self,
            CreateCatalog.self,
        ],
        defaultSubcommand: List.self)
}

struct Options: ParsableArguments {
    @Option(name: [.long, .customShort("d")], help: "Path to a Tarot database")
    var database: String?
}

extension Tarot {
    struct Print: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Print an object by reference.")

        @OptionGroup var options: Options

        @Argument(help: "Object identifier")
        var reference: Int

        mutating func run() {
            let manager = createManager(options: options)

            print("Node: \(reference)")
            
            guard let object: Object = manager.graph.node(reference) ?? manager.graph.link(reference) else {
                fatalError("Unknown object: \(reference)")
            }

            print("Object: \(object)")
        }
    }
}

extension Tarot {
    struct WriteDOT: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Write a Graphviz DOT file.")

        @OptionGroup var options: Options
        
        @Option(name: [.long, .customShort("n")],
                help: "Name of the graph in the output file")
        var name = "output"

        @Option(name: [.long, .customShort("o")],
                help: "Path to a DOT file where the output will be written.")
        var output = "output.dot"

        @Option(name: [.long, .customShort("l")],
                help: "Node attribute that will be used as node label")
        var labelAttribute = "id"
        
        mutating func run() throws {
            let manager = createManager(options: options)
           
            // This is the same validation as in Tarot.Export command
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
            // ^^ --- up until here (from TarotExport)

            let exporter = DotExporter(url: outputURL,
                                       name: name,
                                       labelAttribute: labelAttribute)

            // TODO: Allow export of a selection
            try exporter.export(nodes: Array(manager.graph.nodes),
                                links: Array(manager.graph.links))
        }
    }
}

Tarot.main()
