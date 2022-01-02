//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 30/12/2021.
//

import Records

/// `LinkDescription` describes a link of a trait in a graph. It is used for
/// looking up links in either direction based on the `isReverse` attribute.
public final class LinkDescription {
    // TODO: Change isReverse into enum Direction { outgoing, incoming }
    // TODO: Consider renaming to 'LinkTrait'
    
    public let name: String
    // TODO: This is simplification for more complex predicate matching
    public let linkName: String
    public let isReverse: Bool
    
    /// - Parameters:
    ///
    ///   - name: link name that will be used as an object attribute
    ///   - linkName: name of the link that is referred to by this description
    ///   - isReverse: flag whether we are looking at the reverse
    ///     relationship, that is we are looking at objects where the receiving
    ///     node is a target
    ///
    public required init(_ name: String, _ linkName: String, isReverse: Bool=false) {
        self.name = name
        self.linkName = linkName
        self.isReverse = isReverse
    }
}

extension LinkDescription: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case linkName
        case isReverse
    }
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let linkName = try container.decode(String.self, forKey: .linkName)
        let isReverse = try container.decodeIfPresent(Bool.self, forKey: .isReverse)
        self.init(name, linkName, isReverse: isReverse ?? false)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(linkName, forKey: .linkName)
        try container.encode(isReverse, forKey: .isReverse)
    }
}
