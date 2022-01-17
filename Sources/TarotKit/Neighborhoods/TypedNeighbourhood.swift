//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 12/01/2022.
//

import Records

/// Projection of a neighbourhood of a node where the links are of a specific
/// type.
///
// TODO: This should be rather named LinkProjection
// TODO: Or this might be rather LabelledNeighbourhood
public class TypedNeighbourhood: BaseNodeProjection {
    /// Type of a link that is considered to be part of the neighbourhood.
    let linkType: LinkSelector

    /// Creates a neighbourhood with a specific link type.
    ///
    public init(_ node: Node, linkType: LinkSelector) {
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
   
    /// Get count of links in the neigbourhood.
    ///
    public var count: Int {
        return links.count
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
    public func add(_ node: Node, attributes: [String:Value]=[:]) {
        var linkAttributes = attributes
        linkAttributes[linkType.labelAttribute] = linkType.label
        switch linkType.direction {
        case .incoming: node.connect(to: representedNode, attributes: linkAttributes)
        case .outgoing: representedNode.connect(to: node, attributes: linkAttributes)
        }
    }
}
