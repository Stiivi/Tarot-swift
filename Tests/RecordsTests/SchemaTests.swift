//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//

import Foundation

import XCTest
@testable import Records

final class SchemaTests: XCTestCase {
    func testBasic() throws {
        let schema = Schema(["id", "name"])
        
        XCTAssertEqual(schema.fields,
                       [Field("id"), Field("name")])
        
    }
    
    func testContains() throws {
        let schema = Schema(["id", "name"])

        XCTAssertTrue(schema.contains("id"))
        XCTAssertTrue(schema.contains("name"))
        XCTAssertFalse(schema.contains("unknown"))
    }
    
    func testRename() throws {
        let schema = Schema(["id", "name"])
        let renamed = schema.renamed(["id":"newid", "name":"newname"])

        XCTAssertFalse(renamed.contains("id"))
        XCTAssertFalse(renamed.contains("name"))
        XCTAssertTrue(renamed.contains("newid"))
        XCTAssertTrue(renamed.contains("newname"))
        XCTAssertFalse(renamed.contains("unknown"))
    }
    
    func testIsConvertibleNames() throws {
        let original = Schema(["id", "name", "value"])
        let good = Schema(["name", "id"])
        let bad = Schema(["id", "unknown"])
        
        XCTAssertTrue(good.isConvertible(to: original))
        XCTAssertFalse(bad.isConvertible(to: original))
    }
    func testIsConvertibleTypes() throws {
        let original = Schema(
            [Field("id", type: .int),
             Field("name", type: .string),
             Field("flag", type: .bool)])
        let good = Schema(
            [Field("id", type: .string),
             Field("name", type: .int),
             Field("flag", type: .string)])
        let bad1 = Schema([Field("flag", type: .int)])
        let bad2 = Schema([Field("flag", type: .double)])

        XCTAssertTrue(good.isConvertible(to: original))
        XCTAssertFalse(bad1.isConvertible(to: original))
        XCTAssertFalse(bad2.isConvertible(to: original))
    }
}
