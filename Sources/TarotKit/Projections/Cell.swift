//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 17/01/2022.
//

/// Projection of a cell node - a node that refers to another node as a content
/// node.
///
/// Cells are usually referred to by collection containers. They can be thought
/// as wrappers for the conent node and give the content node attributes that
/// are relevant for the container they are contained in.
///
/// For example a deck of slides or a deck of cards is a container with cells
/// referring to a slide or a card. We might have multiple decks containing the
/// same slide or the same card.
///
/// If we were to model this in a relational database, cell are somewhat
/// analogous to an intermediate relation for a many-to-many relationship.
///
public class Cell: BaseNodeProjection {
    
    /// Selector for the link to the content node.
    let selector: LinkSelector
    
    /// Creates a cell projection for a cell node. Default content of the cell
    /// is a link with default link label attribute `label` and its value
    /// `content`.
    ///
    public init(_ node: Node, selector: LinkSelector = LinkSelector("content")) {
        self.selector = selector
        super.init(node)
    }
    
    /// Get a content node of the cell, if it exists.
    ///
    /// If there are multiple links which match the link selector, then
    /// one is picked arbitrarily.
    ///
    /// - Note: Multiple links to a potential content nodes might exist if
    /// they were created outside of this cell.
    ///
    public func content() -> Node? {
        guard let graph = self.graph else {
            return nil
        }
        
        let first = graph.outgoing(representedNode).first {
            $0[selector.labelAttribute] == selector.label
        }

        // TODO: Does it make sense to consider endpoint?
        return first.map { selector.endpoint($0) }
    }

    /// Set a content node for the cell.
    ///
    /// Setting a content node will first remove all existing links from
    /// the cell node that match the link selector. Then it creates a new
    /// connection with a new content.
    ///
    public func setContent(_ node: Node) {
    }
}
