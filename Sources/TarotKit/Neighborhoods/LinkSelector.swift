//
//  LabelledLinkType.swift
//  
//
//  Created by Stefan Urbanek on 17/01/2022.
//

import Records

/// Designation of which direction of a link from a node projection perspective
/// is to be considered.
///
public enum LinkDirection {
    /// Direction that considers links where the node projection is the target.
    case incoming
    /// Direction that considers links where the node projection is the origin.
    case outgoing
}

/*

 String representation
 
 labelAttribute:label
 
 examples:
 
 - "label:item"
 - "label:thing"
 - "!label:thing" -> reversed

 */

/// Describes links that have a label attribute.
///
public struct LinkSelector {
    /// Label of a link. Links with this label are conforming to this link type.
    public let label: Label
    
    /// Direction of a link.
    public let direction: LinkDirection
    
    /// Create a labelled link type.
    ///
    /// - Properties:
    ///     - label: Label of links that conform to this type
    ///     - direction: Direction of links to be considered when relating
    ///       to a projected node.
    public init(_ label: Label, direction: LinkDirection = .outgoing) {
        self.label = label
        self.direction = direction
    }
    
    /// Return a list of links associated with the node that match the selector.
    // TODO: Equivalent exists in NodeProjection.links, one should go
    public func links(with node: Node) -> [Link] {
        let links: [Link]
        switch direction {
        case .incoming: links = node.incoming
        case .outgoing: links = node.outgoing
        }
        
        return links.filter { $0.contains(label: label) }
    }

    /// Returns endpoint of the link based on the direction. Returns link's
    /// origin if the direction is ``LinkDirection.incoming`` or returns link's target if the
    /// direction is ``LinkDirection.outgoing``.
    ///
    public func endpoint(_ link: Link) -> Node {
        switch direction {
        case .incoming: return link.origin
        case .outgoing: return link.target
        }
    }
}

