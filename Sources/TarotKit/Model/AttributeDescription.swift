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

    /// Description of the attribute.
    public var description: String? { representedNode["description"]?.stringValue()}

    /// Value type. If it is not present then default `string` is assumed. If it
    /// contains an unknown value type then the type will be `nil`.
    public var type: ValueType? {
        guard let type = representedNode["type"]?.stringValue() else {
            return .string
        }
        switch type {
        case "bool": return .bool
        case "int": return .int
        case "float": return .float
        case "string": return .string
        default: return nil
        }
    }
    
    /// Create a new AttributeDescription projection and its represented node.
    ///
    /// The caller is expected to associate the newly created node with a graph.
    ///
    public init(name: String, title: String?=nil, description:String?=nil,
                            type: ValueType = .string) {
        var attributes: AttributeDictionary = [:]
        attributes["name"] = .string(name)
        attributes["type"] = .string(type.description)
        if let title = title {
            attributes["title"] = .string(title)
        }
        if let desc = description {
            attributes["description"] = .string(desc)
        }
        
        super.init(Node(attributes:attributes))
    }
    
    /// Create a new AttributeDescription as a projection of a node.
    public override init(_ node: Node) {
        super.init(node)
    }
}
