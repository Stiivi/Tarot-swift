//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//


public class TextDocumentSection: BaseNodeProjection {
    /// Title of the section. Usually it will be rendered as a heading.
    ///
    public var title: String? { representedNode["title"]?.stringValue() }
    
    /// Depth level of the section. 0 is a top-level section.
    public var level: Int { representedNode["level"]?.intValue() ?? 0}
    
    public var subsections: IndexedCollection {
        return IndexedCollection(representedNode,
                                 selector:LinkSelector("subsection"),
                                 indexAttribute: "order")
    }

    public var blocks: IndexedCollection {
        return IndexedCollection(representedNode,
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

    /// Source of the document. Usualy an URL
    public var source: String? { representedNode["source"]?.stringValue() }

    /// Title of the document.
    public var title: String? { representedNode["title"]?.stringValue() }

    public var sections: IndexedCollection {
        return IndexedCollection(representedNode,
                                 selector:LinkSelector("subsection"),
                                 indexAttribute: "order")
    }

}
