//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 12/01/2022.
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
public struct LabelledLinkType {
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
    public init(label: Value, direction: LinkDirection = .outgoing,
                labelAttribute: String="label") {
        self.label = label
        self.direction = direction
        self.labelAttribute = labelAttribute
    }
}

/// Projection of a neighbourhood of a node where the links are of a specific
/// type.
///
public class TypedNeighbourhood: BaseNodeProjection {
    /// Type of a link that is considered to be part of the neighbourhood.
    let linkType: LabelledLinkType

    /// Creates a neighbourhood with a specific link type.
    ///
    public init(_ node: Node, linkType: LabelledLinkType) {
        self.linkType = linkType
        super.init(node)
    }
    
    /// Links in the neighbourhood of the represented node. The neghborhood
    /// links are all links where the represented node is an origin or a target
    /// (depends on the link type) and which match the link type pattern.
    ///
    /// Order of the links is unspecified. More concrete types of neighbourhood
    /// can return links in an order that is related to that neighbourhood.
    ///
    public var links: [Link] {
        guard let graph = representedNode.graph else {
            return []
        }

        let links: [Link]

        switch linkType.direction {
        case .incoming:
            links = graph.incoming(representedNode).filter {
                $0[linkType.labelAttribute] == linkType.label
            }
        case .outgoing:
            links = graph.outgoing(representedNode).filter {
                $0[linkType.labelAttribute] == linkType.label
            }
        }
        
        return links
    }
    
    /// Nodes in the neighbourhood of the represented node. The neghborhood
    /// nodes are all adjacent nodes where the link matches the link type
    /// pattern.
    ///
    /// Order of the nodes is unspecified. More concrete types of neighbourhood
    /// can return nodes in an order that is related to that neighbourhood.
    ///
    /// - Complexity: Typically same as complexity for
    /// ``TypedNeighbourhood/links-swift.type.property``. Please refer to the
    /// property in a concrete subclass of the neighbourhood.
    ///
    public var nodes: [Node] {
        let nodes: [Node]
        
        switch linkType.direction {
        case .incoming: nodes = links.map { $0.origin }
        case .outgoing: nodes = links.map { $0.target }
        }
        
        return nodes
    }
    
    /// Adds a node to the neighbourhood.
    ///
    /// If the link direction is `outgoing` then the represented node is the
    /// link's origin and the `node` is link's target. If the link direction is
    /// `incoming` then the origin is `node` and the target is the represented
    /// node.
    ///
    /// - Attention: Do not call this method directly. Subclasses can call this
    ///  method to create a correct link type.
    ///
    func add(_ node: Node, attributes: [String:Value]=[:]) {
        var linkAttributes = attributes
        linkAttributes[linkType.labelAttribute] = linkType.label
        switch linkType.direction {
        case .incoming: node.connect(to: representedNode, attributes: linkAttributes)
        case .outgoing: representedNode.connect(to: node, attributes: linkAttributes)
        }
    }
}
