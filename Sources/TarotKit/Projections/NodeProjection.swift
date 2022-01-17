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
    // TODO: Implement: neighbours(name: String) -> [Node]
    var representedNode: Node { get }
    
    /// Attribute of a link that contains the link label. There are links that
    /// have their own semantics which can be derived from the link label.
    ///
    /// Default link label attribute is `label`.
    ///
    var defaultLinkLabelAttribute: String  { get }

    /// Return outgoing links with default label attribute equal to ``label``.
    func outgoing(label: String) -> [Link]

    /// Return incoming links with default label attribute equal to ``label``.
    func incoming(label: String) -> [Link]

}

extension NodeProjection {
    public var graph: Graph? {
        return representedNode.graph
    }

    public var defaultLinkLabelAttribute: String  {
        representedNode["default_link_label_attribute"]?.stringValue() ?? "label"
    }

    public func outgoing(label: String) -> [Link] {
        let links: [Link]
        links = representedNode.outgoing.filter { link in
            link[defaultLinkLabelAttribute]?.stringValue() == label
        }
        return links
    }

    public func incoming(label: String) -> [Link] {
        let links: [Link]
        links = representedNode.incoming.filter { link in
            link[defaultLinkLabelAttribute]?.stringValue() == label
        }
        return links
    }
}

public class BaseNodeProjection: NodeProjection {
    public var representedNode: Node
    
    init(_ node: Node) {
        self.representedNode = node
    }
}
