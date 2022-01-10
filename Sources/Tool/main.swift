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
            Print.self,
            WriteDOT.self,
        ],
        defaultSubcommand: List.self)
}

struct Options: ParsableArguments {
    @Option(name: [.long, .customShort("d")], help: "Path to a Tarot database")
    var database = "Data.tarot"
}

extension Tarot {
    struct Create: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Create an empty Tarot database.")

        @OptionGroup var options: Options

        mutating func run() {
            let url = URL(fileURLWithPath: options.database, isDirectory: true)

            do {
                try FilePackageStore.initialize(url: url)
            }
            catch {
                fatalError("Unable to create a file storage: \(error)")
            }
        }
    }
}

extension Tarot {
    struct List: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "List nodes.")

        @OptionGroup var options: Options

        mutating func run() {
            let space = makeSpace(options: options)
            for node in space.memory.nodes {
                let traitName = node.trait?.name ?? "no trait"
                print("\(node.id!)(\(traitName))")
            }
        }
    }
}

extension Tarot {
    struct Print: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Print an object by reference.")

        @OptionGroup var options: Options

        @Argument(help: "Object identifier")
        var reference: Int

        mutating func run() {
            let space = makeSpace(options: options)

            print("Node: \(reference)")
            
            guard let object: Object = space.memory.node(reference) ?? space.memory.link(reference) else {
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


        
        mutating func run() {
            let space = makeSpace(options: options)
            
            let exporter = DotExporter(path: output,
                                       name: name,
                                       labelAttribute: labelAttribute)

            // TODO: Allow export of a selection
            exporter.export(nodes: Array(space.memory.nodes),
                            links: Array(space.memory.links))
        }
    }
}

Tarot.main()
