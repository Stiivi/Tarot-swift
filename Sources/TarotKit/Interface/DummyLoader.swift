//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 07/01/2022.
//

import Foundation


/// A loader that loads nothing. Development placeholder.
///
public class DummyLoader: Loader {
    public required init(manager: GraphManager) {
        print("Dummy loader created.")
        // Do nothing
    }
    
    public func load(from: URL) throws -> Node? {
        print("Dummy loader pretends loading, in fact it does nothing.")
        return nil
        // Do nothing
    }
    
}
