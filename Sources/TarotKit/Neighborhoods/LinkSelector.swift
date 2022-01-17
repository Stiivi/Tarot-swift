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

/// Describes links that have a label attribute.
///
public struct LinkSelector {
    /// Label of a link. Links with this label are conforming to this link type.
    public let label: Value
    
    /// Direction of a link.
    public let direction: LinkDirection
    
    /// Attribute to be used to determine the label of a link. Default is
    /// "label".
    public let labelAttribute: String
    
    /// Create a labelled link type.
    ///
    /// - Properties:
    ///     - label: Label of links that conform to this type
    ///     - direction: Direction of links to be considered when relating
    ///       to a projected node.
    ///     - labelAttribute: Link attribute that contains the label. Default
    ///       is `label`.
    ///
    public init(_ label: Value, direction: LinkDirection = .outgoing,
                labelAttribute: String="label") {
        self.label = label
        self.direction = direction
        self.labelAttribute = labelAttribute
    }
    
    /// Returns endpoind of the link based on the direction. Returns link's
    /// origin if the direction 
    ///
    public func endpoint(_ link: Link) -> Node {
        switch direction {
        case .incoming: return link.origin
        case .outgoing: return link.target
        }
    }
}

