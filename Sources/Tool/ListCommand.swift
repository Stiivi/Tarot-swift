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
    struct List: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "List named nodes")

        @OptionGroup var options: Options

        mutating func run() {
            let space = openSpace(options: options)
            
            guard let catalog = space.catalog else {
                fatalError("Database has no catalog.")
            }
            
            for key in catalog.keys {
                print(key)
            }
        }
    }
}

