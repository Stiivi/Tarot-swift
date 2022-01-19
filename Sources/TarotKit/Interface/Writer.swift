//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 19/01/2022.
//

import Foundation

/// Writer is a protocol for objects that are writing graphs as a
/// sequence of links and nodes.
///
/// Some graph writers might support storing named references – names of
/// nodes that might have special meaning during the loading process.
///
public protocol GraphWriter {
    func write(graph: Graph, names: [String:Node]) throws
}
