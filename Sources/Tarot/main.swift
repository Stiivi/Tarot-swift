//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//
import GraphMemory
import Foundation
import ArgumentParser


/// Create a space from a package specified in the options.
///
func makeSpace(options: Options) -> Space {
    let space: Space
    let packageURL = URL(fileURLWithPath: options.packagePath, isDirectory: true)

    do {
        space = try Space(packageURL: packageURL)
    }
    catch ImportError.validationError(let issues) {
        for issue in issues {
            print(issue)
        }
        fatalError("Validation errors found. Abandoning.")
    }
    catch {
        fatalError("Unable to create space: \(error)")
    }
    
    return space
}


// The Command
// ------------------------------------------------------------------------

struct Tarot: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Tarot utility.",
        subcommands: [
            List.self,
            Print.self,
            WriteDOT.self,
        ],
        defaultSubcommand: List.self)
}

struct Options: ParsableArguments {
    @Option(name: [.long, .customShort("p")], help: "Path to a package directory")
    var packagePath = "Data.tarot"
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
            
            guard let object = space.memory.object(reference) else {
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
        
        @Option(name: [.long, .customShort("o")],
                help: "Path to a DOT file where the output will be written.")
        var output = "tarot.dot"

        mutating func run() {
            let space = makeSpace(options: options)
            space.memory.writeDot(path: output, name: "cards")
        }
    }
}

Tarot.main()
