//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 11/01/2022.
//

import Foundation
import TarotKit
import ArgumentParser

// TODO: Merge with PrintCommand, use --format=id
extension Tarot {
    struct List: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "List all nodes")
        @OptionGroup var options: Options

        mutating func run() {
            let manager = createManager(options: options)

            for node in manager.graph.nodes {
                print(node.id!)
            }
        }
    }
}

extension Tarot {
    struct Catalog: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "List named nodes from the catalog and their IDs")
        @OptionGroup var options: Options

        mutating func run() {
            let manager = createManager(options: options)
            
            guard let catalog = manager.catalog else {
                fatalError("Database has no catalog.")
            }
            
            for key in catalog.keys {
                let object = catalog[key]!
                print("\(key)\t\(object.id!)")
            }
        }
    }
}

