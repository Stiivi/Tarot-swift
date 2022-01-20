//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//

import Foundation
import TarotKit
import ArgumentParser

let defaultDatabase = "data.tarot"
let databaseEnvironment = "TAROT_DB"

/// Get the database URL. The database location can be specified by options,
/// environment variable or as a default name, in respective order.
func databaseURL(options: Options) -> URL {
    let location: String
    let env = ProcessInfo.processInfo.environment
    
    if let path = options.database {
        location = path
    }
    else if let path = env[databaseEnvironment] {
        location = path
    }
    else {
        location = defaultDatabase
    }
    
    if let url = URL(string: location) {
        if url.scheme == nil {
            return URL(fileURLWithPath: location, isDirectory: true)
        }
        else {
            return url
        }
    }
    else {
        fatalError("Malformed database location: \(location)")
    }
}

/// Opens a graph from a package specified in the options.
///
func createManager(options: Options) -> GraphManager {
    let manager: GraphManager
    let dataURL = databaseURL(options: options)

    do {
        manager = try GraphManager(contentsOf: dataURL)
    }
    catch {
        fatalError("Unable to open store at: \(dataURL). Reason: \(error)")
    }
    
    return manager
}

/// Finalize operations on graph and save the graph to its store.
///
func finalizeManager(manager: GraphManager, options: Options) throws {
    let dataURL = databaseURL(options: options)
    let writer = TarotFileWriter(url: dataURL)

    try manager.save(using: writer)
}
