//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//

import Foundation

// TODO: Status: Experimental
/// Protocol for objects that load graphs from a source into a graph memory.
///
public protocol Loader {
    /// Create a loader and associate it with a space.
    ///
    init(space: Space)
    
    /// Load graph from `source` into the associated space.
    /// 
    func load(from source: URL) throws
}

// TODO: Status: Idea
public protocol Reader {
    /// Model that describes the graph provided by the reader. If the reader
    /// does not provide any model then the value is `nil`.
    var model: Model? { get }
    
    /// Name of node groups if the reader provides nodes in different named
    /// groups, for example namespaces. If the reader provides only one group,
    /// it might return an empty list.
    ///
    var nodeGroups: [String] { get }
    
    /// List of nodes in a named group. If `nil` is provided then default
    /// group is assumed.
    ///
    func nodes(in group: String?) -> [Node]

    /// List of links in a named group. If `nil` is provided then default
    /// group is assumed.
    ///
    func links(in group: String?) -> [Link]
}

