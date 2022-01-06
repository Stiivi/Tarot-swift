//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//

import Records

/// Projection of a node that represents a collection of items that are ordered
/// by index.
///
public class IndexedCollection: Collection {
    public var linkIndexAttribute: String {
        representedNode["linkIndexAttribute"]?.stringValue() ?? "index"
    }
    override public var linkOrderAttribute: String {
        linkIndexAttribute
    }

    /// Get links ordered by index
    public var linksByIndex: [Link] {
        // TODO: What about corrupted ones with invalid or empty index?
        orderedItemLinks(orderBy: linkIndexAttribute)
    }
    
    /// Get collection items ordered by index.
    override public var items:[Node] {
        return linksByIndex.map { $0.target }
    }
    
    /// Get a link to the first node in the collection.
    public var firstLink: Link? { linksByIndex.first }

    /// Get a link to the last node in the collection.
    public var lastLink: Link? { linksByIndex.last }

    /// End index of the collection. All indexes in the collection are lower
    /// than the end index. One can use it in iteration:
    ///
    /// ```swift
    /// let collection: IndexedCollection
    ///
    /// for index in 1..<endIndex {
    ///     let node = collection.node(at: index)
    ///     // do something with the node
    /// }
    ///
    public var endIndex: Int {
        if let link = lastLink {
            // TODO: We might run into an integrity issue here
            // If a link exists but the index attribute is not convertible to int
            if let index = link[linkIndexAttribute]?.intValue() {
                return index + 1
            }
            else {
                return 0
            }
        }
        else {
            return 0
        }
    }

    /// Append a node to the end of the collection.
    ///
    /// - Parameters:
    ///     - node: Node to be appended
    ///     - attributes: Additional attributes to be set on the link to the node
    ///
    /// This function creates a link from the represented object of the
    /// collection to the node. The function will set special projection
    /// attributes of the link such as label and index value.
    ///
    public func append(_ node: Node, attributes: [String:Value] = [:]) {
        let index = endIndex
        
        var linkAttributes = attributes
        
        linkAttributes[itemLinkLabelAttribute] = .string(itemLinkValue)
        linkAttributes[linkIndexAttribute] = .int(index)

        representedNode.connect(to: node, attributes: linkAttributes)
    }
    
    /// Return a node at index `index` or `nil` when there is no node at that
    /// index. There might be no node at given index if the index is out of
    /// bounds or when the represented node has broken integrity.
    ///
    public func node(at index: Int) -> Node? {
        let links = linksByIndex
        guard index >= 0 && index < links.count else {
            return nil
        }
        return links[index].target
    }
}
