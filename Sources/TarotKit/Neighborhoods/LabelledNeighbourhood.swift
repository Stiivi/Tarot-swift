//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 12/01/2022.
//

import Records

/// Projection of a neighbourhood of a node where the links are matching a given
/// link selector.
///
public class LabelledNeighbourhood: BaseNodeProjection {
    /// Type of a link that is considered to be part of the neighbourhood.
    let selector: LinkSelector

    /// Creates a neighbourhood with a specific link selector.
    ///
    public init(_ node: Node, selector: LinkSelector) {
        self.selector = selector
        super.init(node)
    }
    
    /// Links in the neighbourhood of the represented node. The neghborhood
    /// links are all links where the represented node is an origin or a target
    /// (depends on the link selector) and which match the link selector pattern.
    ///
    /// Order of the links is unspecified. More concrete types of neighbourhood
    /// can return links in an order that is related to that neighbourhood.
    ///
    public var links: [Link] {
        guard let graph = representedNode.graph else {
            return []
        }

        let links: [Link]

        switch selector.direction {
        case .incoming:
            links = graph.incoming(representedNode).filter {
                $0[selector.labelAttribute] == selector.label
            }
        case .outgoing:
            links = graph.outgoing(representedNode).filter {
                $0[selector.labelAttribute] == selector.label
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
    /// nodes are all adjacent nodes where the link matches the link selector
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
        
        switch selector.direction {
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
    ///  method to create a correct link selector.
    ///
    /// - Returns: A link that connects the node that has been added to the
    ///   neighbourhood.
    ///
    @discardableResult
    public func add(_ node: Node, attributes: [String:Value]=[:]) -> Link {
        var linkAttributes = attributes
        linkAttributes[selector.labelAttribute] = selector.label
        let link: Link
        switch selector.direction {
        case .incoming: link = node.connect(to: representedNode, attributes: linkAttributes)
        case .outgoing: link = representedNode.connect(to: node, attributes: linkAttributes)
        }
        return link
    }

    /// Remove all links from the neighbourhood.
    ///
    public func disconnectAll() {
        guard let graph = self.graph else {
            // Nothing to disconnect here
            return
        }
        
        for link in links {
            graph.disconnect(link: link)
        }
    }
}
