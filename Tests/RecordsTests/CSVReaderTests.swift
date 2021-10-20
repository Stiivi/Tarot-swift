import XCTest
@testable import Records

final class CSVReaderTests: XCTestCase {
    func testEmptyReader() throws {
        var reader:CSVReader
        var token: CSVReader.Token
        
        reader = CSVReader("")
        token = reader.nextToken()
        
        XCTAssertEqual(token, .empty)
    }

    func testWhitespaceRows() throws {
        var reader:CSVReader
        var token: CSVReader.Token
        
        reader = CSVReader(" ")
        token = reader.nextToken()
        XCTAssertEqual(token, .value(" "))
        token = reader.nextToken()
        XCTAssertEqual(token, .empty)
        
        reader = CSVReader("\n")
        token = reader.nextToken()
        XCTAssertEqual(token, .recordSeparator)
        token = reader.nextToken()
        XCTAssertEqual(token, .empty)
    }
    
    func testRowTokens() throws {
        var reader:CSVReader
        var token: CSVReader.Token
        
        reader = CSVReader("one,two,three")
        token = reader.nextToken()
        XCTAssertEqual(token, .value("one"))
        token = reader.nextToken()
        XCTAssertEqual(token, .fieldSeparator)
        token = reader.nextToken()
        XCTAssertEqual(token, .value("two"))
        token = reader.nextToken()
        XCTAssertEqual(token, .fieldSeparator)
        token = reader.nextToken()
        XCTAssertEqual(token, .value("three"))
        token = reader.nextToken()
        XCTAssertEqual(token, .empty)
    }
    func testQuote() throws {
        var reader:CSVReader
        var token: CSVReader.Token
        
        reader = CSVReader("\"quoted\"")
        token = reader.nextToken()
        XCTAssertEqual(token, .value("quoted"))
        token = reader.nextToken()
        XCTAssertEqual(token, .empty)
        
        reader = CSVReader("\"quoted,comma\"")
        token = reader.nextToken()
        XCTAssertEqual(token, .value("quoted,comma"))
        token = reader.nextToken()
        XCTAssertEqual(token, .empty)
        
        reader = CSVReader("\"quoted\nnewline\"")
        token = reader.nextToken()
        XCTAssertEqual(token, .value("quoted\nnewline"))
        token = reader.nextToken()
        XCTAssertEqual(token, .empty)
    }
    func testQuoteEscape() throws {
        var reader:CSVReader
        var token: CSVReader.Token
        
        reader = CSVReader("\"\"\"\"")
        token = reader.nextToken()
        XCTAssertEqual(token, .value("\""))
        token = reader.nextToken()
        XCTAssertEqual(token, .empty)
    }
    func testWeirdQuote() throws {
        var reader:CSVReader
        var token: CSVReader.Token
        
        // The following behavior was observed with Numbers and with MS Word
        
        // This is broken but should be parsed into a signle quote value
        reader = CSVReader("\"\"\"")
        token = reader.nextToken()
        XCTAssertEqual(token, .value("\""))
        token = reader.nextToken()
        XCTAssertEqual(token, .empty)

        // This is broken but should be parsed into a signle quote value
        reader = CSVReader("\"quoted\" value")
        token = reader.nextToken()
        XCTAssertEqual(token, .value("quoted value"))
        token = reader.nextToken()
        XCTAssertEqual(token, .empty)
    }
    
    func testRow() throws {
        var reader: CSVReader
        var row: [String]?
        
        reader = CSVReader("one,two,three")
        row = reader.next()
        
        XCTAssertEqual(row, ["one", "two", "three"])
        XCTAssertNil(reader.next())
    }

    func testQuotedRow() throws {
        var reader: CSVReader
        var row: [String]?
        
        reader = CSVReader("one,\"quoted value\",three")
        row = reader.next()
        
        XCTAssertEqual(row, ["one", "quoted value", "three"])
    }

    func testMultipleRows() throws {
        var reader: CSVReader
        var row: [String]?
        
        reader = CSVReader("11,12,13\n21,22,23\n31,32,33")
        row = reader.next()
        XCTAssertEqual(row, ["11", "12", "13"])
        row = reader.next()
        XCTAssertEqual(row, ["21", "22", "23"])
        row = reader.next()
        XCTAssertEqual(row, ["31", "32", "33"])
    }

}
