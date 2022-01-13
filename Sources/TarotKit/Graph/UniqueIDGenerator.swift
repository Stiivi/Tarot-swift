//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 03/01/2022.
//

import Foundation

/// Protocol for generators of unique object IDs.
///
public protocol UniqueIDGenerator {
    
    /// Returns a next unique ID.
    func next() -> OID
    
    /// Marks an ID to be already used. Prevents the generator from generating
    /// it. This is useful, for example, if the generator is providing IDs from
    /// a known pool of unique IDs, such as sequence of numbers.
    ///
    /// Default implementation is provided and it does nothing.
    ///
    func markUsed(_ id: OID)
}


extension UniqueIDGenerator {
    func markUsed(_ id: OID) {
        // Do nothing
    }
}

/// Generator of IDs as a sequence of numbers starting from 1.
///
/// Subsequent sequential order is not guaranteed.
///
public class SequenceIDGenerator: UniqueIDGenerator {
    var sequence: Int
    
    public init() {
        sequence = 1
    }
    
    public func next() -> OID {
        let id = sequence
        sequence += 1
        return id
    }

    public func markUsed(_ id: OID) {
        // This is a very primitive
        if id > sequence {
            sequence = id + 1
        }
    }
}
