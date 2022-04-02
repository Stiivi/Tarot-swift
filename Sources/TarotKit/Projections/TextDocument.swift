//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//


/// A projection of a node that represents a section of a text tat can contain
/// blocks and subsections.
///
/// Blocks and subsections are represented as indexed labelled neighbourhoods,
/// see ``IndexedCollection`` for more information.
///
public class TextDocumentSection: BaseNodeProjection {
    /// Title of the section. Usually it will be rendered as a heading.
    ///
    public var title: String? { representedNode["title"]?.stringValue() }
    
    /// Depth level of the section. A top-level section has depth of 0 (zero).
    public var level: Int { representedNode["level"]?.intValue() ?? 0}
    
    /// Labelled neighbourhood of text subsections. The links are labelled
    /// as `subsection` and using the attribute `order` to determine the
    /// subsection order within the section.
    ///
    public var subsections: IndexedNeighbourhood {
        return IndexedNeighbourhood(representedNode,
                                 selector:LinkSelector("subsection"),
                                 indexAttribute: "order")
    }

    /// Labelled neighbourhood of text blocks. The links are labelled
    /// as `block` and using the attribute `order` to determine the
    /// order of the blocks in the section.
    ///
    public var blocks: IndexedNeighbourhood {
        return IndexedNeighbourhood(representedNode,
                                 selector:LinkSelector("block"),
                                 indexAttribute: "order")
    }
}


/// A projection of a node that represents a piece of a text. The text is
/// stored in an attribute named `text` and is expected to be a string value.
///
public class TextBlock: BaseNodeProjection {
    /// Raw text of the section.
    public var text: String? { representedNode["text"]?.stringValue() }
}


/// Projection of a node that represents a text document at it's highest level.
///
/// The text document is composed of sections which usually represents chapters.
///
public class TextDocument: BaseNodeProjection {

    /// Source of the document. Usualy an URL. Projected from the attribute
    /// `source`.
    public var source: String? { representedNode["source"]?.stringValue() }

    /// Title of the document. Projected from the attribute `title`
    public var title: String? { representedNode["title"]?.stringValue() }

    /// Labelled neighbourhood of text sections. The links are labelled
    /// as `subsection` and using the attribute `order` to determine the
    /// subsection order within the section. See ``TextDocumentSection`` for
    /// more information.
    ///
    public var sections: IndexedNeighbourhood {
        return IndexedNeighbourhood(representedNode,
                                 selector:LinkSelector("subsection"),
                                 indexAttribute: "order")
    }

}
