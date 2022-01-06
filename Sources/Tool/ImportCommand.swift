//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 03/01/2022.
//

import Foundation
import TarotKit
import ArgumentParser

extension Tarot {
    struct Import: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Import graph from an external resource, such as file")

        @OptionGroup var options: Options

        @Argument(help: "Tabular package")
        var packageURL: String

        mutating func run() throws {
            let space = makeSpace(options: options)
            let url = URL(fileURLWithPath: packageURL)
            try space.loadPackage(from: url)
            try finalizeSpace(space: space, options: options)
        }
    }
}


