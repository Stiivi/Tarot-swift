//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 03/01/2022.
//

import Foundation
import TarotKit
import ArgumentParser

struct Import: ParsableCommand {
    static var configuration
        = CommandConfiguration(
            abstract: "Import graph from an external resource",
            discussion: """
Imports a graph from a file, directory or an URL.
                        
Available formats: auto, package, markdown. `auto` means that the format will be
guessed.
""")

    @OptionGroup var options: Options

    @Option(name: [.long, .customShort("f")],
            help: "Format of the resource.")
    var format = "auto"
    
    @Option(name: [.long, .customShort("n")],
            help: "Name of import's represented object in the catalog.")
    var name = "last_import"
    
    @Argument(help: "Resource path or URL")
    var source: String

    mutating func run() throws {
        let manager = createManager(options: options)
        guard let testURL = URL(string: source) else {
            fatalError("Invalid resource reference: \(source)")
        }
        
        let sourceURL: URL

        if testURL.scheme == nil {
            sourceURL = URL(fileURLWithPath: source)
        }
        else {
            sourceURL = testURL
        }

        let format: String
        
        /* Guess the format based on the URL */

        if self.format == "auto" {
            if sourceURL.pathExtension == "tarotpackage" {
                format = "package"
            }
            else if sourceURL.pathExtension == "md" {
                format = "markdown"
            }
            else if sourceURL.pathExtension == "markdown" {
                format = "markdown"
            }
            else if sourceURL.pathExtension == "txt" {
                format = "markdown"
            }
            else if !sourceURL.isFileURL {
                // We assume that directory URLs are a package URLs
                format = "package"
            }
            else {
                // TODO: For now we assume just a package format
                // (this might seem redundant to the !isFileURL rule, but
                //  we keep it here explicit intentionally)
                format = "package"
            }
        }
        else {
            format = self.format
        }
        
        let loader: Loader
        
        switch format {
        case "package":
            loader = RelationalPackageLoader(manager: manager)
        case "markdown":
            loader = MarkdownLoader(manager: manager)
        default:
            fatalError("Unknown input format: \(format)")
        }
        // FIXME: !!! THIS !!!
        // reader = PackageReader()
        // reader.open()
        // reader.close()
        
        
        if let importedNode = try loader.load(from: sourceURL) {
            if let catalog = manager.catalog {
                catalog.setKey(name, for: importedNode)
                print("Import finished. Imported object name: \(name)")
            }
            else {
                print("Import finished. Database has no catalog, import node name was ignored.")
            }
        }
        else {
            print("Import finished. No represented object created by import, import node name was ignored.")
        }
        
        try finalizeManager(manager: manager, options: options)
    }
}


