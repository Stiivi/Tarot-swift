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
        abstract: "Tarot graph utility.",
        subcommands: [
            CreateDB.self,
            CreateCatalog.self,
            CreateNode.self,
            Remove.self,
            SetAttribute.self,
            Connect.self,
            List.self,
            Catalog.self,
            Print.self,
            Import.self,
            Export.self,
            WriteDOT.self,
        ],
        defaultSubcommand: List.self)
}

struct Options: ParsableArguments {
    @Option(name: [.long, .customShort("d")], help: "Path to a Tarot database")
    var database: String?
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
