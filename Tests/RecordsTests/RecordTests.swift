//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/10.
//

import Foundation

import XCTest
@testable import Records

final class RecordTests: XCTestCase {
    func testGetValues() throws {
        let schema = Schema(["number", "label"])
        let r = Record(schema: schema, ["number": 1, "label": "one"])
        
        XCTAssertEqual(try r.stringValue(of: "label"), "one")
        XCTAssertEqual(try r.intValue(of: "number"), 1)
    }
    func testKeyError() throws {
        let schema = Schema(["number", "label"])
        let r = Record(schema: schema, ["number": 1, "label": "one"])
        var error: RecordError?
        
        XCTAssertThrowsError(try r.stringValue(of: "unknown")) {
            error = $0 as? RecordError
        }
        
        XCTAssertEqual(error, RecordError.fieldNotFound("unknown"))
    }
    func testValueNotFoundError() throws {
        try XCTSkipIf(true, "Exception throwing is removed for now")

        let schema = Schema(["label"])
        let r = Record(schema: schema)
        var error: RecordError?
        
        XCTAssertThrowsError(try r.stringValue(of: "label")) {
            error = $0 as? RecordError
        }
        
        XCTAssertEqual(error, RecordError.valueNotFound("label"))
    }
    func testTypeMismatchError() throws {
        try XCTSkipIf(true, "Exception throwing is removed for now")
        let schema = Schema(["label"])
        let r = Record(schema: schema, ["label": "one"])
        var error: RecordError?
        
        XCTAssertThrowsError(try r.intValue(of: "label")) {
            error = $0 as? RecordError
        }
        
        XCTAssertEqual(error, RecordError.typeMismatch("label", .int))

        XCTAssertThrowsError(try r.boolValue(of: "label")) {
            error = $0 as? RecordError
        }
        
        XCTAssertEqual(error, RecordError.typeMismatch("label", .bool))

        XCTAssertThrowsError(try r.doubleValue(of: "label")) {
            error = $0 as? RecordError
        }
        
        XCTAssertEqual(error, RecordError.typeMismatch("label", .double))
    }

}

