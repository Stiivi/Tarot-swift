//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 03/01/2022.
//

import XCTest
import Markdown

@testable import TarotKit


final class MarkdownReaderTests: XCTestCase {
    func testAcceptEmptyContentBlock() throws {
        let document = Markdown.Document(parsing: "")
        let reader = MarkdownReader(document: document)

        let block = reader.acceptContentBlock()
        
        XCTAssertNil(block)
    }

    func testAcceptNotEmptyContentBlock() throws {
        let text = """
                   One
                   
                   - Item 1
                   - Item 2

                   1. First
                   2. Secong
                   """
        let document = Markdown.Document(parsing: text)
        let reader = MarkdownReader(document: document)
        
        XCTAssertNotNil(reader.acceptContentBlock())
        XCTAssertNotNil(reader.acceptContentBlock())
        XCTAssertNotNil(reader.acceptContentBlock())
        XCTAssertNil(reader.acceptContentBlock())
        XCTAssertNil(reader.acceptContentBlock())
    }
    
    func testAcceptContentBlockNoHeading() throws {
        let text = """
                   One

                   # Chapter 1
                   """
        let document = Markdown.Document(parsing: text)
        let reader = MarkdownReader(document: document)
        
        XCTAssertNotNil(reader.acceptContentBlock())
        XCTAssertNil(reader.acceptContentBlock())
        XCTAssertNil(reader.acceptContentBlock())
    }
    func testAccpetSections() throws {
        let text = """
                   # One
                   
                   # Two
                   """
        let document = Markdown.Document(parsing: text)
        let reader = MarkdownReader(document: document)

        let sec1 = reader.acceptSection(0)
        
        XCTAssertNotNil(sec1)
        XCTAssertEqual(sec1!.level, 1)
        XCTAssertEqual(sec1!.title, "One")
        XCTAssertTrue(sec1!.blocks.isEmpty)
        XCTAssertTrue(sec1!.subsections.isEmpty)

        let sec2 = reader.acceptSection(0)
        XCTAssertNotNil(sec2)
        XCTAssertEqual(sec2!.level, 1)
        XCTAssertEqual(sec2!.title, "Two")
        XCTAssertTrue(sec2!.blocks.isEmpty)
        XCTAssertTrue(sec2!.subsections.isEmpty)

        XCTAssertNil(reader.acceptSection(0))
    }
    func testAccpetNonemptySection() throws {
        let text = """
                   # Section 1
                   
                   Text
                   
                   - One
                   - Two
                   
                   ## Subsection 1

                   ## Subsection 2
                   
                   # Section 2
                   """
        let document = Markdown.Document(parsing: text)
        let reader = MarkdownReader(document: document)

        let sec1 = reader.acceptSection(0)
        
        XCTAssertNotNil(sec1)
        XCTAssertEqual(sec1!.level, 1)
        XCTAssertEqual(sec1!.title, "Section 1")
        XCTAssertEqual(sec1!.blocks.count, 2)
        XCTAssertEqual(sec1!.subsections.count, 2)

        XCTAssertEqual(sec1!.subsections[0].level, 2)
        XCTAssertEqual(sec1!.subsections[1].level, 2)

        XCTAssertEqual(sec1!.subsections[0].title, "Subsection 1")
        XCTAssertEqual(sec1!.subsections[1].title, "Subsection 2")

        
        let sec2 = reader.acceptSection(0)
        
        XCTAssertNotNil(sec2)
        XCTAssertEqual(sec2!.level, 1)
        XCTAssertEqual(sec2!.title, "Section 2")
        XCTAssertEqual(sec2!.blocks.count, 0)
        XCTAssertEqual(sec2!.subsections.count, 0)

        XCTAssertNil(reader.acceptSection(0))
    }
    func testAcceptEmptyDocument() throws {
        let text = ""
        let document = Markdown.Document(parsing: text)
        let reader = MarkdownReader(document: document)
        XCTAssertNil(reader.acceptDocument())
    }

    func testAccpetNoSectionsDocument() throws {
        let text = """
                   Text
                   
                   - One
                   - Two
                   """
        let document = Markdown.Document(parsing: text)
        let reader = MarkdownReader(document: document)

        let doc = reader.acceptDocument()
        
        XCTAssertNotNil(doc)
        XCTAssertEqual(doc!.level, 0)
        XCTAssertNil(doc!.title)
        XCTAssertEqual(doc!.blocks.count, 2)
        XCTAssertEqual(doc!.subsections.count, 0)
    }
    func testAccpetDocument() throws {
        let text = """
                   # Section 1

                   ## Section 1.1

                   ## Section 1.2

                   # Section 2

                   ## Section 2.1
                   """
        let document = Markdown.Document(parsing: text)
        let reader = MarkdownReader(document: document)

        let doc = reader.acceptDocument()
        
        XCTAssertNotNil(doc)
        XCTAssertEqual(doc!.level, 0)
        XCTAssertNil(doc!.title)
        XCTAssertEqual(doc!.blocks.count, 0)
        XCTAssertEqual(doc!.subsections.count, 2)
        XCTAssertEqual(doc!.subsections[0].title, "Section 1")
        XCTAssertEqual(doc!.subsections[1].title, "Section 2")
    }
    func testAccpetDocumentWithPrologue() throws {
        let text = """
                   In the beginning
                   
                   - One
                   - Two
                   
                   > Quote.
                   
                   # Section 1

                   # Section 2
                   
                   The End.
                   """
        let document = Markdown.Document(parsing: text)
        let reader = MarkdownReader(document: document)

        let doc = reader.acceptDocument()
        
        XCTAssertNotNil(doc)
        XCTAssertEqual(doc!.level, 0)
        XCTAssertNil(doc!.title)
        XCTAssertEqual(doc!.blocks.count, 3)
        XCTAssertEqual(doc!.subsections.count, 2)
        XCTAssertEqual(doc!.subsections[0].title, "Section 1")
        XCTAssertEqual(doc!.subsections[1].title, "Section 2")
        XCTAssertEqual(doc!.subsections[1].blocks.count, 1)
    }
}
