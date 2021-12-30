//
//  File.swift
//
//
//  Created by Stefan Urbanek on 30/12/2021.
//

@testable import GraphMemory

class Thing: Node {
    let label: String
    
    init(_ label: String) {
        self.label = label
    }
}
