//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/24.
//

import Foundation

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
    
    enum CodingKeys: String, CodingKey {
        case name
        case traits
    }
    
    /// Creates a model with traits.
    ///
    required public init(name: String, traits: [Trait]) {
        self.name = name
        self.traits = traits
    }
   
    /// Get a trait with given name.
    ///
    /// - Returns: a trait if the trait with the given name is found,
    ///            otherwise `nil`.
    public func trait(name: String) -> Trait? {
        return traits.first { $0.name == name }
    }
    
    
    /// Merge another model into this model. The new model replaces the entities
    /// in existing model.
    ///
    // TODO: Handle conflict resolution
    // TODO: Notify that the model has changed
    public func merge(_ model: Model) {
        var newTraits: [String:Trait] = [:]
        for trait in traits {
            newTraits[trait.name] = trait
        }
        
        for trait in model.traits {
            newTraits[trait.name] = trait
        }
        
        traits = Array(newTraits.values)
    }
}

extension Model: Codable {
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let traits = try container.decode(Array<Trait>.self, forKey: .traits)

        let name = try container.decode(String.self, forKey: .name)

        self.init(name: name, traits: traits)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .traits)
        try container.encode(traits, forKey: .traits)
    }
}
