//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 03/01/2022.
//

import Foundation
import Markdown


public struct Walker: MarkupWalker {
    var collected: [BlockMarkup] = []
    public typealias Result = Void
    
    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
        collected.append(blockQuote)
        let x = blockQuote as! Markup
    }
    public mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        collected.append(codeBlock)
    }
    public mutating func visitCustomBlock(_ customBlock: CustomBlock) -> Result {
        collected.append(customBlock)
    }
//    public mutating func visitDocument(_ document: Document) -> Result {
//        return defaultVisit(document)
//    }
    public mutating func visitHeading(_ heading: Heading) -> Result {
        return defaultVisit(heading)
    }
    public mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> Result {
        return defaultVisit(thematicBreak)
    }
    public mutating func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        return defaultVisit(html)
    }
    public mutating func visitListItem(_ listItem: ListItem) -> Result {
        return defaultVisit(listItem)
    }
    public mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        return defaultVisit(orderedList)
    }
    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        return defaultVisit(unorderedList)
    }
    public mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        return defaultVisit(paragraph)
    }
    public mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
        return defaultVisit(blockDirective)
    }
    public mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        return defaultVisit(inlineCode)
    }
    public mutating func visitCustomInline(_ customInline: CustomInline) -> Result {
        return defaultVisit(customInline)
    }
    public mutating func visitEmphasis(_ emphasis: Emphasis) -> Result {
        return defaultVisit(emphasis)
    }
    public mutating func visitImage(_ image: Image) -> Result {
        return defaultVisit(image)
    }
    public mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        return defaultVisit(inlineHTML)
    }
    public mutating func visitLineBreak(_ lineBreak: LineBreak) -> Result {
        return defaultVisit(lineBreak)
    }
    public mutating func visitLink(_ link: Markdown.Link) -> Result {
        return defaultVisit(link)
    }
    public mutating func visitSoftBreak(_ softBreak: SoftBreak) -> Result {
        return defaultVisit(softBreak)
    }
    public mutating func visitStrong(_ strong: Strong) -> Result {
        return defaultVisit(strong)
    }
    public mutating func visitText(_ text: Text) -> Result {
        return defaultVisit(text)
    }
    public mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> Result {
        return defaultVisit(strikethrough)
    }
    public mutating func visitTable(_ table: Table) -> Result {
        return defaultVisit(table)
    }
    public mutating func visitTableHead(_ tableHead: Table.Head) -> Result {
        return defaultVisit(tableHead)
    }
    public mutating func visitTableBody(_ tableBody: Table.Body) -> Result {
        return defaultVisit(tableBody)
    }
    public mutating func visitTableRow(_ tableRow: Table.Row) -> Result {
        return defaultVisit(tableRow)
    }
    public mutating func visitTableCell(_ tableCell: Table.Cell) -> Result {
        return defaultVisit(tableCell)
    }
    public mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> Result {
        return defaultVisit(symbolLink)
    }
}

//public class MarkdownSection: NodeView {
//    
//}

public class MarkdownLoader: Loader {
    public var document: Document! = nil
    public var nodes: [Node] = []
    public var links: [Link] = []
    public var stack: [Node] = []
    public var currentHeading: Heading?
    public var currentNode: Node?
    
    let space: Space
    
    required public init(space: Space) {
        self.space = space
        let text: String = "text"
        fatalError("Not implemented")
    }
    
    public func load(from source: URL) throws {
        fatalError("Not implemented")
    }
    
    public func walk() {
        for child in document.children {
            if let heading = child as? Heading {
                // We got a heading
                visitHeading(heading)
            }
            else if let block = child as? BlockMarkup {
                visitBlock(block)
                // We got a block markup
            }
            else {
                // This should not happen ...
                fatalError("Unhandled markdown child: \(child)")
            }
        }
    }
    public func visitHeading(_ heading: Heading) {
        if let current = currentHeading {
            if heading.level == current.level {
                
            }
            else if heading.level > current.level {
//                stack.append()
            }
            else if heading.level < current.level {
                
            }
        }
        else {
            currentHeading = heading
            let node = Node()
            node["title"] = .string(heading.plainText)
            node["type"] = "title"
        }
    }
    public func visitBlock(_ block: BlockMarkup) {
        
    }
}
