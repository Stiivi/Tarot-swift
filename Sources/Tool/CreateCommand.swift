//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 11/01/2022.
//

import Foundation
import TarotKit
import ArgumentParser

extension Tarot {
    struct CreateDB: ParsableCommand {
        static var configuration
            = CommandConfiguration(
                commandName: "create-db",
                abstract: "Create an empty Tarot database."
            )

        @OptionGroup var options: Options

        mutating func run() throws {
            let manager = GraphManager()

            let catalogNode = manager.graph.create()
            manager.setCatalog(catalogNode)

            let url = databaseURL(options: options)
            let writer = TarotFileWriter(url: url)
            
            do {
                try manager.save(using: writer)
            }
            catch {
                fatalError("Unable to create store: \(error)")
            }
        }
    }
}

extension Tarot {
    struct CreateCatalog: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Create empty catalog if it does not exist")

        @OptionGroup var options: Options

        mutating func run() throws {
            let manager = createManager(options: options)
            
            guard manager.catalog == nil else {
                print("Catalog already exists. Not creating.")
                CreateCatalog.exit()
            }
            
            let catalog = manager.graph.create()
            manager.setCatalog(catalog)

            print("Catalog created.")
            try finalizeManager(manager: manager, options: options)
        }
    }
}
