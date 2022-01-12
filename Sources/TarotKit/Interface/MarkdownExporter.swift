//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 11/01/2022.
//

import Foundation
import Markdown

public class MarkdownExporter {
    public init() {
        
    }
    /// Export a node that can be projected as a textDocument
    ///
    public func export(textDocument: Node) -> Document {
        let document = TextDocument(textDocument)
        var blocks: [BlockMarkup] = []

        // Collect subsections
        if let title = document.title {
            let heading = Heading(level: 1, Text(title))
            blocks.append(heading)
        }

        for subsection in document.sections {
            // TODO: Why unwrap when we wrap later?
            blocks += sectionNodeToMarkup(node: subsection)
        }
        
        let md = Document(blocks)
        
        return md
    }
    
    public func sectionNodeToMarkup(node: Node) -> [BlockMarkup]{
        let section = TextDocumentSection(node)
        var blocks: [BlockMarkup] = []
        
        if let title = section.title {
            let heading = Heading(level: section.level, Text(title))
            blocks.append(heading)
        }
        
        // Collect blocks
        for node in section.blocks {
            let block = TextDocumentBlock(node)
            guard let text = block.text else {
                // No text, we pass
                continue
            }
            let md = Document(parsing: text)
            blocks += Array(md.blockChildren)
        }

        // Collect subsections
        for subsection in section.subsections {
            // TODO: Why unwrap when we wrap later?
            blocks += sectionNodeToMarkup(node: subsection)
        }
        
        return blocks
    }
}


