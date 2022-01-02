//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 26/12/2021.
//

import Records

extension GraphMemory {
    /// Create an ordered node collection
    public func orderedNodeCollection() -> [Node] {
       return []
    }
}

/// View of a node representing a collection.
///
/// A collection node is a node that has several specific links to other nodes
/// that are considered collection's items.
///
/// - Parameters:
///
///     - node: The node representing the collection.
///     - itemLinkAttribute: attribute of the node which contains name of an
///       attribute of a links pointing to the items. Default value is `label`
///     - itemLinkValue: value of the `itemLinkAttribute` that specifies the
///       collection's items. Default value is `item`.
///     - linkSortAttribute: optional name of a link attribute that is used
///       to order the items. If not specified then the order is undefined.
///
/// For example let us have nodes representing paragraphs.
/// We would like to create a chapter, which is a collection of the paragraphs.
/// Then the chapter would be a collection node and paragraphs would be
/// collection's items.
///
/// Because the system does not enforce any specific link labelling, we follow
/// the labelling we have created for our space. Say we label the links under
/// link's attribute `label`. Then our collection's ``itemLinkAttribute`` would
/// be `label` and ``itemLinkValue`` woul be `item`. Example of such link would
/// be:
///
/// ```swift
/// graph.connect(from: chapter,
///               to: paragraph,
///               attributes:["label":"link"])
/// ```
///
/// Now we want the paragraphs in the chapter ordered, so we do:
///
/// ```swift
/// graph.connect(from: chapter,
///               to: paragraph,
///               attributes:["label":"link", "order": "1"])
/// ```
///
/// We add other paragraphs in a similar fashion. And then create a collection:
///
/// ```swift
/// let collection = Collection(chapter)
/// ```
///
public class Collection {
    /// Node representing the collection
    var representedNode: Node
    /// Name of a link property to be looked at when locating collection
    /// members. Typically it would be `name`.
    ///
    var itemLinkAttribute: String  { representedNode["itemLinkAttribute"]?.stringValue() ?? "label"}
    
    /// Value of the item forming link property. Typically it would be `item`
    ///
    var itemLinkValue: String { representedNode["itemLinkValue"]?.stringValue() ?? "item" }
    var linkOrderAttribute: String? { representedNode["linkOrderAttribute"]?.stringValue() }
    
    // TODO: NULLS FIRST/LAST
    
    /// Creates a collection rooted in `node`.
    ///
    public init(_ node: Node) {
        self.representedNode = node
    }
    
    /// List of collection items.
    ///
    var items: [Node] {
        return itemLinks.map { $0.target }
    }
    
    /// List of links that point to the collection items.
    ///
    // TODO: Distinguish between ordered and un-ordered
    var itemLinks: [Link] {
        guard let outgoing = representedNode.graph?.outgoing(representedNode) else {
            // FIXME: I guess this should be an error
            return []
        }
        var links: [Link] = outgoing.filter { link in
            link[itemLinkAttribute]?.stringValue() == itemLinkValue
            }
        if let linkOrderAttribute = self.linkOrderAttribute {
            links.sort { left, right in
                guard let lhs = left[linkOrderAttribute] else {
                    return false
                }
                guard let rhs = right[linkOrderAttribute] else {
                    return false
                }
                return lhs.isLessThan(other: rhs)
                
            }
        }
        
        return links
    }
    
    /// Add a node to the collection.
    ///
    func add(node item: Node, attributes: [String:Value] = [:]) {
        var linkAttributes = attributes
        
        linkAttributes[itemLinkAttribute] = .string(itemLinkValue)

        representedNode.graph?.connect(from: representedNode, to: item, attributes: linkAttributes)
    }
}
