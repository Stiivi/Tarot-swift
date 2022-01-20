//
//  Loader.swift
//  
//
//  Created by Stefan Urbanek on 07/01/2022.
//

import Foundation
import Records

/// Protocol for objects that load graphs from a source into a graph.
///
/// - Status: Experimental
///
public protocol Loader {
    /// Create a loader and associate it with a graph manager
    ///
    // TODO: Remove this requirement
    init(graph: Graph)
    
    /// Loads nodes and links from `source` into a graph.
    ///
    /// The loader returns a a name dictionary – external
    /// references to imported objects. Caller might use that information
    /// to do some post-loading object linking.
    ///
    /// - Parameters:
    ///   - source: URL of a resource to be loaded into the graph
    ///   - preserveIdentity: Flag whether the loader sohuld preserve IDs from
    ///     the source and set the internal IDs to be the same.
    ///
    /// It is up to the caller of this method how the linking of the named
    /// nodes is performed after the loading. For example the command-line tool
    /// uses a node named `batch` and links it with the catalog under the name
    /// `last_import`. ``TarotFileLoader`` provides a name `catalog` which
    /// points to a node representing a node catalog. This is used, for example,
    /// when loading a new graph into the graph manager. Can be used for
    /// merging two catalogs.
    ///
    /// - Tip: It is recommended that the loader returns at least one named
    /// node. Returned node represents the loadeded batch, document or a
    /// collection of items. Suggested name is `batch` to make it work
    /// with the import command.
    ///
    /// Objects implementing the method should throw an
    /// ``LoaderError/preserveIdentityNotSupported`` error if they
    /// are asked to preserve identity but they can not preserve it. For
    /// example if there is no identity at the source.
    ///
    /// - Note: For the time being, the loaders preserving identity should
    /// throw an error if an object with supposed identity already exists.
    ///
    /// - Returns:Dictionary of named nodes that have been loaded. The
    /// keys are object names, the values are the nodes.
    ///
    func load(from source: URL, preserveIdentity: Bool) throws -> [String:Node]
}

/// Errors raised by objects conforming to ``Loader``.
///
/// Some of the cases have a custom context information value. This can be
/// a reference to a container in the source if there are multiple, or
/// location information into a file, or any other useful information
/// that the user can use to porentially correct the problem.
///
public enum LoaderError: Error, Equatable {
    /// Raised by the loader when it is asked to preserve identity of nodes
    /// or links and when the loader does not support the feature.
    case preserveIdentityNotSupported
    
    // FIXME: This is
    
    /// Source is missing an ID for a node or a link. The value is a custom
    /// context information.
    case missingSourceID(String)
    
    /// A duplicate ID at the source has been found – two nodes or two links
    /// at the source have the same ID.
    ///
    /// First value is the duplicate ID, the second value is a custom context
    /// information.
    case duplicateSourceID(Value, String)

    /// The type of an ID in the source can not be converted to the internal
    /// ID.
    ///
    /// First value is the malformed ID, the second value is a custom context
    /// information.
    case sourceIDTypeMismatch(Value, String)
    
    /// Record is missing a required attribute or a field.
    ///
    /// First value is an attribute name. The second value is a custom context
    /// information.
    case missingAttribute(String, String)
    
    /// A node with given key can not be find. The second value is a context of
    /// the node, for example a container, relation or a resource name.
    case unknownNode(Value, String)
}
