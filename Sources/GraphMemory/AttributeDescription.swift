//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 30/12/2021.
//

import Foundation
import Records

/// Describes an object's attribute.
///
public final class AttributeDescription {
    /// Attribute name
    public let name: String
    public let valueType: ValueType
    
    /// Create an attribute description.
    ///
    /// - Parameters:
    ///
    ///   - name: property name that will be used as an object attribute.
    ///   - label: label of a link that is used for user interface. If not
    ///     provided then `name` will be used.
    ///   - valueType: type of the property value. Default is `string`
    ///
    public required init(_ name: String, valueType: ValueType = .string) {
        self.name = name
        self.valueType = valueType
    }
}

extension AttributeDescription: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case label
        case valueType
    }
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let valueType = try container.decodeIfPresent(ValueType.self, forKey: .valueType)
        self.init(name, valueType: valueType ?? .string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(valueType, forKey: .valueType)
    }
}

