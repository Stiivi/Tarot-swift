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
    
    /// Returns a next unique object ID.
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
/// Subsequent sequential order continuity is not guaranteed.
///
/// - Note: This is very primitive and naive sequence number generator. If an ID
///   is marked as used and the number is higher than current sequence, all
///   numbers are just skipped and the next sequence would be the used +1.
///   
public class SequenceIDGenerator: UniqueIDGenerator {
    /// ID as a sequence number.
    var sequence: Int
    
    /// Creates a sequential ID generator and initializes the sequence to 1.
    public init() {
        sequence = 1
    }
    
    /// Gets a next sequence id.
    public func next() -> OID {
        let id = sequence
        sequence += 1
        return id
    }

    public func markUsed(_ id: OID) {
        // This is a very primitive
        if id >= sequence {
            sequence = id + 1
        }
    }
}
