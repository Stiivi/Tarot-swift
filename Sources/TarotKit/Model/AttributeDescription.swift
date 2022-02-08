//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 07/02/2022.
//

import Foundation
import Records

/// Node that represents an attribute description.
public class AttributeDescription: BaseNodeProjection {
    /// Attribute name
    public var name: String? { representedNode["name"]?.stringValue() }

    /// Human-readable title. If not present then name is used.
    public var title: String? { representedNode["title"]?.stringValue() ?? name}

    /// Value type. If it is not present or contains an unknown value type
    /// then the type will be `nil`.
    public var type: ValueType? {
        guard let type = representedNode["type"]?.stringValue() else {
            return nil
        }
        switch type {
        case "bool": return .bool
        case "int": return .int
        case "float": return .float
        case "string": return .string
        default: return nil
        }
    }
}
