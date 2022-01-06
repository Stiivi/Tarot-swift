//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//

import Foundation
import TarotKit
import ArgumentParser

/// Create a space from a package specified in the options.
///
func makeSpace(options: Options) -> Space {
    let space: Space
    let dataURL = URL(fileURLWithPath: options.database, isDirectory: true)
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
//    catch LoaderError.validationError(let issues) {
//        for issue in issues {
//            print(issue)
//        }
//        fatalError("Validation errors found. Abandoning.")
//    }
//    catch {
//        fatalError("Unable to create space: \(error)")
//    }
    
    return space
}

/// Finalize operations on space and save the space to its store.
///
func finalizeSpace(space: Space, options: Options) throws {
    let dataURL = URL(fileURLWithPath: options.database, isDirectory: true)
    let store: FilePackageStore
    do {
        store = try FilePackageStore(url: dataURL)
    }
    catch {
        fatalError("Unable to open database at: \(dataURL). Reason: \(error)")
    }

    try space.save(to: store)
}
