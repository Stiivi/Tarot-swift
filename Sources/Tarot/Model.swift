//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//

import Foundation
import Records
import GraphMemory

var CardTrait = Trait(
    name: "Card",
    links: [
        LinkDescription("amplifies", "amplifies"),
        LinkDescription("amplified_by", "amplifies", isReverse: true),
        LinkDescription("inhibits", "inhibits"),
        LinkDescription("inhibited_by", "inhibits", isReverse: true),
        LinkDescription("requires", "requires"),
        LinkDescription("required_by", "requires", isReverse: true),

        LinkDescription("suffer_missing", "suffer-missing"),
        LinkDescription("suffer_present", "suffer-present"),
        LinkDescription("suffer_each", "suffer-each"),
    ],
    properties: [
        PropertyDescription("name"),
        PropertyDescription("type"),
        PropertyDescription("side"),
        PropertyDescription("domain"),
        PropertyDescription("status"),
        PropertyDescription("level", valueType: .int),
        PropertyDescription("text"),

        PropertyDescription("engPower", valueType: .int),
        PropertyDescription("compPower", valueType: .int),
        PropertyDescription("storage", valueType: .int),

        PropertyDescription("threat", valueType: .int),
        PropertyDescription("confusion", valueType: .int),
        PropertyDescription("complexity", valueType: .int),
        PropertyDescription("consistency", valueType: .int),
        PropertyDescription("speed", valueType: .int),
        PropertyDescription("quality", valueType: .int),
        PropertyDescription("trust", valueType: .int),
        PropertyDescription("adaptability", valueType: .int),
        PropertyDescription("security", valueType: .int),
    ]
    
)

class Card: Node, RecordRepresentable, CustomStringConvertible, CustomDebugStringConvertible {
    static var recordSchema: Schema {
        Schema([
            Field("name", isUnique: true),
            Field("type", isRequired: true),
            Field("side", isRequired: true),
            Field("domain", isRequired: true),
            Field("status"),
            Field("level", type: .int, isRequired: true),
            Field("text"),

            Field("engPower", type: .int),
            Field("compPower", type: .int),
            Field("storage", type: .int),

            Field("threat", type: .int),
            Field("confusion", type: .int),
            Field("complexity", type: .int),
            Field("consistency", type: .int),
            Field("speed", type: .int),
            Field("quality", type: .int),
            Field("trust", type: .int),
            Field("adaptability", type: .int),
            Field("security", type: .int),

        ])
    }

    var name: String
    var type: String
    var side: String
    var domain: String
    var status: String
    var level: Int
    var text: String

    var engPower: Int
    var compPower: Int
    var storage: Int
    
    var threat: Int
    var confusion: Int
    var complexity: Int
    var speed: Int
    var quality: Int
    var trust: Int
    var adaptability: Int
    var security: Int
    
    required init(record: Record) throws {
        name = try record.stringValue(of: "name")!
        type = try record.stringValue(of: "type")!
        side = try record.stringValue(of: "side")!
        domain = try record.stringValue(of: "domain")!
        status = try record.stringValue(of: "status")!
        text = try record.stringValue(of: "text") ?? ""
        level = try record.intValue(of: "level") ?? 0

        engPower = try record.intValue(of: "engPower") ?? 0
        compPower = try record.intValue(of: "compPower") ?? 0
        storage = try record.intValue(of: "storage") ?? 0
        
        threat = try record.intValue(of: "threat") ?? 0
        confusion = try record.intValue(of: "confusion") ?? 0
        complexity = try record.intValue(of: "complexity") ?? 0
        speed = try record.intValue(of: "speed") ?? 0
        quality = try record.intValue(of: "quality") ?? 0
        trust = try record.intValue(of: "trust") ?? 0
        adaptability = try record.intValue(of: "adaptability") ?? 0
        security = try record.intValue(of: "security") ?? 0
    }
    
    func recordRepresentation() -> Record {
        fatalError("recordRepresentation not implemented")
    }
    
    public var description: String { name }
    public var debugDescription: String {
        "Card(\(name))"
    }

    
}
