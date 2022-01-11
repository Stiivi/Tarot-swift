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

/// Opens a space from a package specified in the options.
///
func openSpace(options: Options) -> Space {
    let space: Space
    let dataURL = databaseURL(options: options)
    let store: FilePackageStore

    do {
        store = try FilePackageStore(url: dataURL)
    }
    catch {
        fatalError("Unable to open database at: \(dataURL). Reason: \(error)")
    }
    
    do {
        space = try Space(store: store)
    }
    catch {
        fatalError("Unable to initialize space: \(error)")
    }
    
    return space
}

/// Finalize operations on space and save the space to its store.
///
func finalizeSpace(space: Space, options: Options) throws {
    let dataURL = databaseURL(options: options)
    let store: FilePackageStore

    do {
        store = try FilePackageStore(url: dataURL)
    }
    catch {
        fatalError("Unable to open database at: \(dataURL). Reason: \(error)")
    }

    try space.save(to: store)
}
