//
//  NodeProjection.swift
//  
//
//  Created by Stefan Urbanek on 02/01/2022.
//

import Foundation

// TODO: Add validation.

/*
 Validation:
 
 func validate() -> [ValidationIssue]
 
 struct ValidationIssue {
    let error: Error
    let description: String
    let suggestion: String
    let canBeAutofixed: Bool
 }
 
 */

/// Node projection is a kind of object that provides additional, more complex
/// operations on a `representedNode` node and its surroundings.
///
/// An example might be treating a node as if it represented a collection
/// of other nodes. The collection view might consider specific kinds of links
/// as references to collection's items.
///
public protocol NodeProjection {
    var representedNode: Node { get }
}
