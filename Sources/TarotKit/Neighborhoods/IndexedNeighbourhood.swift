//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//

import Records

// TODO: Rename to IndexedNeighbourhood
/// Indexed collection is a neighbourhood where links are indexed by an index
/// attribute.
///
public class IndexedNeighbourhood: LabelledNeighbourhood {
    /// Attribute of the links in the neighbourhood that holds an index within
    /// the collection. Default is `index`.
    ///
    /// When modifying the collection, for example by adding or remoing the
    /// items, the neighbourhood projection manages the index attribute. The
    /// attribute of the links will be rewritten.
    ///
    public let linkIndexAttribute: String

    /// Creates a projection for an indexed collection.
    public init(_ node: Node, selector: LinkSelector, indexAttribute: String = "index") {
        self.linkIndexAttribute = indexAttribute
        super.init(node, selector: selector)
    }

    /// Get links ordered by index.
    ///
    /// - Complexity: O(n log n), where n is number of links in the
    /// neighbourhood.
    ///
    override public var links: [Link] {
        var links = super.links
        links.sort { left, right in
            guard let lhs = left[linkIndexAttribute] else {
                // TODO: This is arbitrary decision where we place invalid empty index
                return false
            }
            guard let rhs = right[linkIndexAttribute] else {
                // TODO: This is arbitrary decision where we place invalid empty index
                return false
            }
            return lhs.isLessThan(other: rhs)
        }
        return links
    }
    
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
    /// ```
    ///
    /// - Complexity: O(n log n), where n is number of links in the
    /// neighbourhood.
    ///
    public var endIndex: Int {
        if let link = links.last {
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
    /// - Complexity: O(n log n), where n is number of links in the
    /// neighbourhood.
    ///
    /// - Note: This function assumes that this neighbourhood is completely
    ///         managed by it.
    ///
    /// - Returns: A link that connects the node that has been added to the
    ///   neighbourhood.
    ///
    @discardableResult
    public func append(_ node: Node, attributes: [String:Value] = [:]) -> Link {
        let index = endIndex
        
        var linkAttributes = attributes
        linkAttributes[linkIndexAttribute] = .int(index)

        return self.add(node, attributes:linkAttributes)
    }
   
    /// Remove all links to the node. Reindex the links after the removed node.
    ///
    public func remove(_ node: Node) {
        var index = 0
       
        // Rebuild the collection
        //
        for link in links {
            if link.target === node {
                graph?.disconnect(link: link)
            }
            else {
                if link[linkIndexAttribute] != .int(index) {
                    link[linkIndexAttribute] = .int(index)
                    index += 1
                }
            }
        }
    }

    
    /// Return a node at index `index` or `nil` when there is no node at that
    /// index. There might be no node at given index if the index is out of
    /// bounds or when the represented node has broken integrity.
    ///
    /// - Complexity: O(n log n), where n is number of links in the
    /// neighbourhood.
    ///
    public func node(at index: Int) -> Node? {
        let links = self.links
        guard index >= 0 && index < links.count else {
            return nil
        }
        return links[index].target
    }
}
