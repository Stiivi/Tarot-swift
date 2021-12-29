//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/24.
//

import Foundation
import GraphMemory

enum ModelError: Error {
    case unableToLoadData(URL)
}

/// Model describes the semantics of the nodes and their links.
///
public final class Model {
    public var traits: [Trait]
    
    /// Name of the model.
    ///
    public var name: String
    
    /// Human readable name of the model
    ///
    public var label: String
    
    /// Description of the model.
    ///
    public var description: String?

    enum CodingKeys: String, CodingKey {
        case name
        case label
        case description
        case traits
    }
    
    /// Creates a model with traits.
    ///
    required public init(name: String, label: String?=nil,
                         description: String?=nil, traits: [Trait]) {
        self.name = name
        self.label = label ?? name
        self.description = description
        self.traits = traits
    }
   
    /// Get a trait with given name.
    ///
    /// - Returns: a trait if the trait with the given name is found,
    ///            otherwise `nil`.
    public func trait(name: String) -> Trait? {
        return traits.first { $0.name == name }
    }
}

extension Model: Codable {
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let traits = try container.decode(Array<Trait>.self, forKey: .traits)

        let name = try container.decode(String.self, forKey: .name)
        let label = try container.decodeIfPresent(String.self, forKey: .label)
        let description = try container.decodeIfPresent(String.self, forKey: .description)

        self.init(name: name, label: label, description: description,
                  traits: traits)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .traits)
        try container.encode(label, forKey: .traits)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(traits, forKey: .traits)
    }
}
