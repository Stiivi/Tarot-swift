//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 26/12/2021.
//

import Records

/// Projection of a node representing a collection of nodes.
///
/// A collection node is a node that has several specific links to other nodes
/// that are considered collection's items.
///
/// The projected node might optionally contain the following attributes that
/// will be considered when working with the collection:
///
/// - ``itemLinkLabelAttribute``: attribute of the node which contains name of an
///       attribute of a links pointing to the items. Default value is `label`
/// - ``itemLinkValue``: value of the ``itemLinkLabelAttribute`` that specifies the
///       collection's items. Default value is `item`.
/// - ``linkOrderAttribute``: optional name of a link attribute that is used
///       to order the items. If not specified then the order is undefined.
///
/// For example let us have nodes representing paragraphs.
/// We would like to create a chapter, which is a collection of the paragraphs.
/// Then the chapter would be a collection node and paragraphs would be
/// collection's items.
///
/// Because the system does not enforce any specific link labelling, we follow
/// the labelling we have created for our space. Say we label the links under
/// link's attribute `label`. Then our collection's ``itemLinkLabelAttribute`` would
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
public class Collection: NodeProjection {
    // TODO: Split into Ordered and Unordered Collection
    /// Node representing the collection
    public var representedNode: Node
    /// Name of a link property to be looked at when locating collection
    /// members. Typically it would be `name`.
    ///
    public var itemLinkLabelAttribute: String  {
        representedNode["itemLinkAttribute"]?.stringValue() ?? "label"
    }
    
    /// Value of the item forming link property. Typically it would be `item`
    ///
    public var itemLinkValue: String {
        representedNode["itemLinkValue"]?.stringValue() ?? "item"
    }
    
    /// Attribute that specifies default order of items when ordered items are
    /// requested.
    ///
    // TODO: Move this to OrderedCollection
    // REASON: `items` is returning non-ordered collection of items
    public var linkOrderAttribute: String {
        representedNode["linkOrderAttribute"]?.stringValue() ?? "order"
    }
    
    // TODO: NULLS FIRST/LAST
    
    /// Creates a collection rooted in `node`.
    ///
    public init(_ node: Node) {
        self.representedNode = node
    }
    
    /// List of collection items.
    ///
    public var items: [Node] {
        return itemLinks.map { $0.target }
    }
    
    /// List of links that point to the collection items.
    ///
    public var itemLinks: [Link] {
        let outgoing = representedNode.outgoing

        let links: [Link] = outgoing.filter { link in
            link[itemLinkLabelAttribute]?.stringValue() == itemLinkValue
            }
        
        return links
    }

    /// Number of items in the collection.
    public var count: Int {
        return itemLinks.count
    }

    public enum EmptyOrder {
        case first
        case last
    }

    public func orderedItemLinks(orderBy: String?=nil, empty: EmptyOrder = .first) -> [Link] {
        var links = itemLinks
        let orderByAttribute = orderBy ?? linkOrderAttribute
        
        links.sort { left, right in
            guard let lhs = left[orderByAttribute] else {
                return empty == .last
            }
            guard let rhs = right[orderByAttribute] else {
                return empty == .last
            }
            return lhs.isLessThan(other: rhs)
            
        }

        return links
    }
    

    /// Add a node to the collection.
    ///
    // TODO: This belongs to UnorderedCollection
    public func add(node item: Node, attributes: [String:Value] = [:]) {
        var linkAttributes = attributes
        
        linkAttributes[itemLinkLabelAttribute] = .string(itemLinkValue)

        representedNode.connect(to: item, attributes: linkAttributes)
    }
}

