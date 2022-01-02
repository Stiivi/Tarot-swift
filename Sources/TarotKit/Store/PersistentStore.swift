//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/01/2022.
//

import Foundation

public protocol PersistentStore {
    // TODO: Make sure this is same as Record.id type
    typealias ID = String
    
    /// Save an existing object in the object store
    ///
    func save(record: StoreRecord) throws

    /// Fetch object content from the object store
    ///
    func fetch(id: ID) throws -> StoreRecord?

    /// Fetch all records in the store of given type.
    ///
    func fetchAll(type: String) throws -> [StoreRecord]

    /// Delete an object in the object store.
    ///
    func delete(id: ID) throws
    
    /// Empties and resets the whole store
    ///
    /// Note: This operation is very destructive.
    // FIXME: Do we still need this?
    func deleteAll() throws
}
