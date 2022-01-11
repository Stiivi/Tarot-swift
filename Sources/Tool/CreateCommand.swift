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
    struct Create: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Create an empty Tarot database.")

        @OptionGroup var options: Options

        mutating func run() throws {
            let url = databaseURL(options: options)

            do {
                try FilePackageStore.initialize(url: url)
            }
            catch {
                fatalError("Unable to create a file storage: \(error)")
            }

            let space = openSpace(options: options)
            
            let catalog = Node()
            space.memory.add(catalog)
            space.catalog = Dictionary(catalog)

            try finalizeSpace(space: space, options: options)
        }
    }
}

extension Tarot {
    struct CreateCatalog: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Create empty catalog if it does not exist")

        @OptionGroup var options: Options

        mutating func run() throws {
            let space = openSpace(options: options)
            
            guard space.catalog == nil else {
                print("Catalog already exists. Not creating.")
                CreateCatalog.exit()
            }
            
            let catalog = Node()
            space.memory.add(catalog)
            space.catalog = Dictionary(catalog)

            print("Catalog created.")
            try finalizeSpace(space: space, options: options)
        }
    }
}
