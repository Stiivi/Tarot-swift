//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//

import Foundation

import XCTest
@testable import Records

final class RecordSetTests: XCTestCase {
    
    func testFailedInitializer() throws {
        try XCTSkipIf(true)
        let schema = Schema([
            Field("id", type: .int),
            Field("name", type: .int)
        ])
        let bogusSchema = Schema()
        let empty: Array<Value> = []
        let records = RecordSet(schema: schema,[
            Record(schema: schema, empty),
            Record(schema: bogusSchema, empty),
        ])
        
        XCTAssertNil(records)
    }
    func testCSVInitializer() throws {
        let csv = """
        id,name
        1,one
        2,two
        3,three
        """
        
        let records = RecordSet(csvString: csv)
        let fields = records._schema.fields
        
        XCTAssertEqual(fields.count, 2)
        XCTAssertEqual(fields[0], Field("id", type: .string))
        XCTAssertEqual(fields[1], Field("name", type: .string))

        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records.values(of:"id"), ["1","2","3"])
        XCTAssertEqual(records.values(of:"name"), ["one", "two", "three"])
    }
    
    func testCount() throws {
        let schema = Schema([
            Field("id", type: .int),
            Field("name", type: .int)
        ])
        
        let records = RecordSet(schema: schema, [
            Record(schema: schema, [1, "one"]),
            Record(schema: schema, [2, "two"]),
            Record(schema: schema, [3, "two"]),
            Record(schema: schema, [4, "two"]),
            Record(schema: schema, [4, "four"])
        ])
        
        XCTAssertEqual(records.valueCount("id", value: 1), 1)
        XCTAssertEqual(records.valueCount("id", value: 2), 1)
        XCTAssertEqual(records.valueCount("id", value: 3), 1)
        XCTAssertEqual(records.valueCount("id", value: 4), 2)
        XCTAssertEqual(records.valueCount("name", value: "one"), 1)
        XCTAssertEqual(records.valueCount("name", value: "two"), 3)
        XCTAssertEqual(records.valueCount("name", value: "four"), 1)

        XCTAssertEqual(records.valueCount("id", value: "invalid"), 0)
    }
    func testSummary() throws {
        let schema = Schema([
            Field("value", type: .int)
        ])
        
        let records = RecordSet(schema: schema, [
            [10], [20], [20], [30], [30], [30],
        ])
        
        let summary = records.summary(of: "value")
        
        XCTAssertEqual(summary.noneCount, 0)
        XCTAssertEqual(summary.someCount, 6)
        XCTAssertEqual(summary.totalCount, 6)
        XCTAssertEqual(summary.uniqueCount, 3)

    }
    func testSummaryEmptyCount() throws {
        let schema = Schema([
            Field("int", type: .int),
            Field("str", type: .string)
        ])
        
        let records = RecordSet(schema: schema, [
            [1,"one"], [0, ""], ["3", ""],
        ])
        
        XCTAssertEqual(records.summary(of: "int").emptyCount, 1)
        XCTAssertEqual(records.summary(of: "str").emptyCount, 2)

    }

    func testDistinctValues() throws {
        let schema = Schema([
            Field("value", type: .int)
        ])
        
        let records = RecordSet(schema: schema, [
            [10], [20], [20], [30], [30], [30],
        ])
        
        let values = records.distinctValues(of: "value")
        
        XCTAssertEqual(values, [10, 20, 30])

    }
    func testDistinctCount() throws {
        let schema = Schema([
            Field("value", type: .int)
        ])
        
        let records = RecordSet(schema: schema, [
            [10], [20], [20], [30], [30], [30],
        ])
        
        let values = records.distinctCount(of: "value")
        
        XCTAssertEqual(values, [10:1, 20:2, 30:3])

    }
    func testRenamedFiels() throws {
        let schema = Schema([
            Field("id", type: .int),
            Field("name", type: .int)
        ])
        
        let records = RecordSet(schema: schema, [
            Record(schema: schema, [1, "one"]),
            Record(schema: schema, [2, "two"]),
        ])
        
        let renamed = schema.renamed( ["id": "newid", "name": "newname"] )
        
        records.schema = renamed
        
        XCTAssertEqual(records.values(of:"newid"), [1,2])
        XCTAssertEqual(records.values(of:"newname"), ["one", "two"])

        
    }

}
