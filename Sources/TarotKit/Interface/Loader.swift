//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//

import Foundation
import Records

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

/// An object that specifies a link that might be created.
///
public struct LinkSpecification {
    /// Attributes to be set for the link.
    let attributes: [String:Value]

    /// Reference to the origin object. The reference is subject to
    /// interpretation by the loader and the loading context.
    let originReference: String

    /// Reference to the target object. The reference is subject to
    /// interpretation by the loader and the loading context.
    let targetReference: String
}

// TODO: Status: Idea
public protocol Reader {
    /// Validate the source and return a list of issues that were found.
    func validate() -> IssueList
    
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
    func links(in group: String?) -> [LinkSpecification]
}

