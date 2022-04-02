//
//  MarkdownLoader.swift
//  
//
//  Created by Stefan Urbanek on 03/01/2022.
//

// STATUS: Happy

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
    
    let graph: Graph
    
    /// Creates a markdown loader that will load the input into using the
    /// provided graph manager.
    required public init(graph: Graph) {
        self.graph = graph
    }
    
    /// Loads a markdown from a source URL.
    ///
    public func load(from source: URL, preserveIdentity: Bool = false) throws -> [String:Node] {
        guard !preserveIdentity else {
            throw LoaderError.preserveIdentityNotSupported
        }
        
        let document = try Markdown.Document(parsing: source)

        guard let node = load(document: document) else {
            // FIXME: How to handle this situation? This should not be an error
            fatalError("Loading an empty markdown document. We do not know what to do.")
        }

        node["source"] = .string(source.absoluteString)
        
        return ["batch": node]
    }

    /// Loads a markdown document to the graph.
    ///
    public func load(document: Markdown.Document) -> Node? {
        let reader = MarkdownReader(document: document)
        
        guard let topSection = reader.acceptDocument() else {
            return nil
        }

        return loadSection(topSection)
    }
    
    /// Loads a markdown section into the graph by creating a node that
    /// represents the section and nodes representing the section's blocks
    /// and subsections.
    ///
    /// Section node has the following attributes set:
    ///
    /// - `title` – section title extracted from the section heading. Can be
    ///   not set if the section represents the top-level document.
    /// - `level` – level of the section. 0 for top-level document.
    ///
    /// Section has links to block nodes. Block links have `label` attribute
    /// set to `block`.
    ///
    /// Section has links to sub-section nodes. Sub-section links have `label`
    /// attribute set to `subsection`.
    ///
    /// Block and subsection links have an `order` attribute set that represents
    /// order of that element.
    ///
    @discardableResult
    func loadSection(_ section: MarkdownSection) -> Node {
        var attributes: AttributeDictionary = [:]

        if let title = section.title {
            attributes["title"] = .string(title)
        }
        attributes["level"] = .int(section.level)
        let sectionNode = graph.create(attributes: attributes)

        // 1. Load subsections
        for (index, subsection) in section.subsections.enumerated() {
            let node = loadSection(subsection)
            let attributes: AttributeDictionary = [
                "label": "subsection",
                "order": .int(index),
            ]
            graph.connect(from: sectionNode,
                                 to: node,
                                 attributes: attributes)
        }
        
        // 2. Load blocks
        for (index, block) in section.blocks.enumerated() {
            // TODO: Trim the block text using trimmingCharacters(in: .whitespacesAndNewlines)
            let blockAttributes: AttributeDictionary = [
                "label": "block",
                "order": .int(index),
                "text": .string(block.format())
            ]
            let blockNode = Node(attributes: blockAttributes)
            graph.add(blockNode)

            graph.connect(from: sectionNode,
                                 to: blockNode,
                                 attributes: blockAttributes)
        }
        
        return sectionNode
    }
}

/// Structure representing a markdown section.
///
public struct MarkdownSection {
    /// Level of the section. 0 if the section represents the top-level
    /// document.
    let level: Int
    
    /// Title of the section. Can be empty it represents top-level document.
    let title: String?
    
    /// Blocks that directly follow the section heading or a beginning of a
    /// document.
    let blocks: [BlockMarkup]
    
    /// Subsections of the section that are of a lower level.
    let subsections: [MarkdownSection]
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
    
    /// Creates a markdown reader from a markdown document.
    ///
    public init(document: Markdown.Document) {
        self.document = document
        self.iterator = document.children.makeIterator()
        self.current = self.iterator.next()
    }
    
    /// Indicator whether the reader reached the end of the document. `true`
    /// means that the reader is at the end and there are no more blocks
    /// to be read.
    ///
    public var atEnd: Bool { current == nil }

    /// Accept a block and get a next block.
    ///
    public func accept() {
        current = iterator.next()
    }
    
    /// Accepts a document as a top-level markdown section. The document
    /// section will have no title and level will be 0.
    ///
    /// - Returns: `MarkdownSection` if a valid markdown section was present,
    /// otherwise returns `nil`.
    ///
    public func acceptDocument() -> MarkdownSection? {
        var blocks: [BlockMarkup] = []
        var subsections: [MarkdownSection] = []

        while let block = acceptContentBlock() {
            blocks.append(block)
        }
        
        while let subsection = acceptSection(0) {
            subsections.append(subsection)
        }
        
        if blocks.isEmpty && subsections.isEmpty {
            /// There are no blocks in the document
            return nil
        }
        
        let section = MarkdownSection(level: 0,
                                      title: nil,
                                      blocks: blocks,
                                      subsections: subsections)
                
        return section
    }
    
    /// Accepts a markdown section that begins with a heading. The heading
    /// will be section's title.
    ///
    /// Section can contain blocks or sub-sections. Blocks directly follow the
    /// section heading. Sub-sections either directly follow the heading or
    /// they follow blocks.
    ///
    /// Reader reads up until another section on the same or a higher level.
    /// Note that the level order is reversed: 0 is the highest level.
    ///
    /// - Returns: `MarkdownSection` if a valid markdown section was present,
    /// otherwise returns `nil`.
    ///
    public func acceptSection(_ parentLevel: Int) -> MarkdownSection? {
        var blocks: [BlockMarkup] = []
        var subsections: [MarkdownSection] = []

        guard !atEnd else {
            return nil
        }
        
        guard let heading = current as? Heading else {
            // Section must begin with a heading.
            return nil
        }
        
        guard heading.level > parentLevel else {
            return nil
        }
        
        accept()
        
        // 2. Read section content blocks
        
        // We read blocks up until the next heading. All section blocks
        // come before sub-sections. Text is a tree structure without markers
        // to go one level up. Therefore each sub-section will contain
        // all the blocks that follow its heading.
        
        while let block = acceptContentBlock() {
            blocks.append(block)
        }
        
        // Read sub-sections.
        //
        while let subsection = acceptSection(heading.level) {
            subsections.append(subsection)
        }
        
        let section = MarkdownSection(level: heading.level,
                                      title: heading.plainText,
                                      blocks: blocks,
                                      subsections: subsections)
                
        return section
    }
    
    /// Accepts a markdown block that represents a regular content which is not
    /// a heading.
    ///
    /// - Returns: a Node create from the markdown block.
    ///
    public func acceptContentBlock() -> BlockMarkup? {
        guard (current as? Heading) == nil else {
            return nil
        }
        guard !atEnd else {
            return nil
        }
        
        guard let block = current! as? BlockMarkup else {
            fatalError("Something is wrong here")
        }
        accept()
        return block
    }
}
