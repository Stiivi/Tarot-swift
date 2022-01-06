//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/01/2022.
//

import Foundation

public class TextDocumentSection: NodeProjection {
    public var representedNode: Node
    
    /// Title of the section. Usually it will be rendered as a heading.
    ///
    public var title: String? { representedNode["title"]?.stringValue() }
    
    /// Depth level of the section. 0 is a top-level section.
    public var level: Int { representedNode["level"]?.intValue() ?? 0}
    
    /// Raw text of the section.
    public var text: String? { representedNode["text"]?.stringValue() }
   
    init(node: Node) {
        representedNode = node
    }
}

/// Projection of a node that represents a text document at it's highest level.
///
/// The text document is composed of sections which usually represents chapters.
///
public class TextDocument: IndexedCollection {

    /// Source of the document. Usualy an URL
    public var source: String? { representedNode["source"]?.stringValue() }

    /// Title of the document.
    public var title: String? { representedNode["title"]?.stringValue() }

    /// Label of a link pointing to items of the collection.We call text
    /// document items "sections" therefore the link label by default is
    /// `section`.
    ///
    public override var itemLinkValue: String {
        representedNode["itemLinkValue"]?.stringValue() ?? "section"
    }

    public var sections: [TextDocumentSection] {
        return items.map { TextDocumentSection(node: $0) }
        
    }
    
}
