//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 03/01/2022.
//

import Foundation
import Markdown

/// An object that loads a Markdown document and creates one node per document
/// section. Document section is a series of Markdown blocks following a
/// heading. The heading is a section title.
///
/// Section node attributes:
///
/// - `title`: Section node attribute containing section title.
/// - `level`: Section node attribute containing section level.
/// - `source`: Document source URL if was provided. Only in top-level section.
///
/// Block node attributes:
///
/// - `text`: Block node attribute containing text.
///
/// Link attributes and values:
///
/// - `label`: Link label attribute.
///     - `subsection`: Value for the label attribute for links to a subsection.
///     - `block`: Label of a link to a block.
/// - `order`: Sequential order of a block or a section.
///
/// - Note: This is a higher semantic markdown-to-graph converter. It preserves
///         each block as a whole as a text. For example a list blocks is
///         preserved as one node. List is not converted to one node per each
///         list item.
///
public class MarkdownLoader: Loader {
    public var currentHeading: Heading?
    public var currentNode: Node?
    
    let space: Space
    
    required public init(space: Space) {
        self.space = space
    }
    
    public func load(from source: URL) throws {
        let document = try Markdown.Document(parsing: source)

        let node = load(document: document)
        node["source"] = .string(source.absoluteString)
    }

    /// Loads a markdown document to the graph.
    ///
    public func load(document: Markdown.Document) -> Node {
        let reader = MarkdownReader(document: document)
        let topSection = reader.readDocument()

        return loadSection(topSection)
    }
    
    @discardableResult
    func loadSection(_ section: MarkdownSectionSource) -> Node {
        let sectionNode = Node()
        
        if let title = section.title {
            sectionNode["title"] = .string(title)
        }
        sectionNode["level"] = .int(section.level)

        // 1. Load subsections
        for (index, subsection) in section.subsections.enumerated() {
            let node = loadSection(subsection)
            let attributes: AttributeDictionary = [
                "label": "subsection",
                "order": .int(index),
            ]
            space.memory.connect(from: sectionNode,
                                 to: node,
                                 attributes: attributes)
        }
        
        // 2. Load blocks
        for (index, block) in section.blocks.enumerated() {
            let attributes: AttributeDictionary = [
                "label": "block",
                "order": .int(index),
            ]
            space.memory.connect(from: sectionNode,
                                 to: block,
                                 attributes: attributes)
        }
        
        return sectionNode
    }
}

public struct MarkdownSectionSource {
    let level: Int
    let title: String?
    let blocks: [Node]
    let subsections: [MarkdownSectionSource]
}

/// An object that reads a Markdown document and creates one node per document
/// section. Document section is a series of Markdown blocks following a
/// heading. The heading is a section title.
///
/// - Note: This is a higher semantic markdown-to-graph converter. It preserves
///         each block as a whole as a text. For example a list blocks is
///         preserved as one node. List is not converted to one node per each
///         list item.
///
class MarkdownReader {
    let document: Document
    var iterator: MarkupChildren.Iterator
    var current: Markup?
    
    public init(document: Markdown.Document) {
        self.document = document
        self.iterator = document.children.makeIterator()
        self.current = self.iterator.next()
    }
    
    public var atEnd: Bool { current == nil }

    public func advance() {
        current = iterator.next()
    }
    
    public func readDocument() -> MarkdownSectionSource {
        let documentSection = readSection(level: 0)
        return documentSection
    }

    public func readSection(level: Int, title: String?=nil) -> MarkdownSectionSource {
        var blocks: [Node] = []
        var subsections: [MarkdownSectionSource] = []
        
        // Read introductory blocks before the first heading
        while !atEnd && (current as? Heading) == nil {
            let current = self.current!
            let node = Node()
            node["text"] = .string(current.format())
            blocks.append(node)
        }
        
        // Read sections.
        //
        // Each section begins with a heading which becomes the section's title.
        // If we encounter a heading with equal or a higher level, then we
        // are done with this section.
        // If we encounter a heading with a lesser level, then we descend
        // to a sub-section
        //
        while !atEnd {
            if let heading = current as? Heading {
                if heading.level > level {
                    // Higher heading level menas that we are about to read
                    // a subsection
                    //
                    let subtitle = heading.format()
                    let subsection = readSection(level: heading.level, title: subtitle)
                    subsections.append(subsection)
                }
                else {
                    // Equal or higher heading level means that this section
                    // is finished.
                    //
                    break
                }
            }
            else {
                // This should not happen as all non-headings are eaten
                // at the beginning of each (sub-)section
                fatalError("Unexpected non-heading while reading a section")
            }
        }
        
        let section = MarkdownSectionSource(level: level,
                                            title: title,
                                            blocks: blocks,
                                            subsections: subsections)
                
        return section
    }
}
