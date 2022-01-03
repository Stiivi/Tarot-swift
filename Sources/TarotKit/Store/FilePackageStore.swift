//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/01/2022.
//

// TODO: This should be moved into Interfaces as it is used only for reading and writing


import Foundation
import Records

enum FilePackageStoreError: Error {
    case storePathDoesNotExist
    case storePathIsNotDirectory
    case nodesDirectoryDoesNotExist
    case linksDirectoryDoesNotExist

    case unableToEncodeInfo
    case unableToReadInfo
}


/// Information about the file package store.
///
public struct FilePackageStoreInfo: Codable {
    /// Version of the file package store.
    let version: Int
}

/// Store the object memory in a directory with one JSON file per graph object.
///
/// ## File Structure
///
/// The structure of the directory is:
///
/// - `info.json` – metadata about the store, such as version of the writing
///    object
/// - `type_index.json` – mapping between object IDs and their types
/// - `nodes/` – directory with node files, one JSON file per node
/// - `links/` – directory with link files, one JSON file per link
///
/// There might additional object types found in the store, although they should
/// be considered private.
///
/// Example:
///
/// ```
/// Cards.tarot/
///     info.json
///     type_index.json
///     nodes/
///         1.json
///         2.json
///         3.json
///     links/
///         4.json
///         5.json
/// ```
///
/// The object JSON files have the following top-level structure
///
/// - `id`: object's ID
/// - `type`: type of the object, either `node` or `link`
/// - `attributes`: a dictionary with object's attributes
///
/// - Note: This store is not optimized for performance neither robustness. Any
///         external changes to the store might corrupt the store's integrity.
///
public class FilePackageStore: PersistentStore {
    /// Current version of the file package store object.
    ///
    /// Note: This is not the version of the persisted package store.
    ///
    static let currentVersion = 100
    public let rootURL: URL
    public let info: FilePackageStoreInfo
    
    /// Mapping of object IDs to their types.
    ///
    var recordTypeMap: [String:String] = [:]
    
    /// URL to subdirectory where nodes are stored
    ///
    func urlForType(type: String) -> URL {
        rootURL.appendingPathComponent(type, isDirectory: true)
    }

    /// URL to info file
    ///
    var infoURL: URL {
        rootURL.appendingPathComponent("info.json", isDirectory: false)
    }

    /// Create a store that writes objects as JSON files in a directory at given
    /// path. Each object is a single JSON file.
    ///
    convenience public init(path: String) throws {
        try self.init(url: URL(fileURLWithPath: path))
    }
    
    /// Create a store that writes objects as JSON files in a directory at given
    /// path. Each object is a single JSON file.
    ///
    public init(url: URL) throws {
        self.rootURL = url

        let decoder = JSONDecoder()
        let url = try rootURL.appendingPathComponent("info.json", isDirectory: false)
        let data = try Data(contentsOf: url)
        info = try decoder.decode(FilePackageStoreInfo.self, from: data)

        do {
            try recordTypeMap = readIndex(name: "type_index")
        }
        catch {
            // FIXME: Report error
            recordTypeMap = [:]
        }
    }
    
    /// Initialize a directory object store at given path. The method creates
    /// necessary subdirectories.
    ///
    public static func initialize(url: URL) throws {
        guard !isInitialized(url: url) else {
            fatalError("Store is already initialized at '\(url)'")
        }

        let manager = FileManager.default
        
        try manager.createDirectory(at: url,
                                    withIntermediateDirectories: true)

        
        // Create the info.json file
        //
        let infoURL = url.appendingPathComponent("info.json", isDirectory: false)
        let info = FilePackageStoreInfo(version: currentVersion)
        let encoder = JSONEncoder()
        let infoData: Data
        do {
            infoData = try encoder.encode(info)
        }
        catch {
            throw FilePackageStoreError.unableToEncodeInfo
        }

        try infoData.write(to: infoURL)
    }
    
    /// Diagnose the store structure and return list of errors. The diagnosis
    /// checks:
    ///
    /// - existence of the store directory
    /// - existence of store's subdirectories
    ///
    static func diagnose(url: URL) -> [FilePackageStoreError] {
        let manager = FileManager()
        var isDir: ObjCBool = false
        let infoURL = url.appendingPathComponent("info.json", isDirectory: false)

        var errors: [FilePackageStoreError] = []
        
        guard manager.fileExists(atPath: url.path, isDirectory: &isDir) else {
            // No reason to continue here
            return [.storePathDoesNotExist]
        }
        guard isDir.boolValue else {
            // No reason to continue here
            return [.storePathIsNotDirectory]
        }
        if !manager.fileExists(atPath: infoURL.path) {
            // No reason to continue here
            errors.append(.unableToReadInfo)
        }

        // TODO: Check known types and rebuild index
        
        return errors
    }
    
    /// Checks whether the store is properly initialized at given path.
    ///
    static func isInitialized(url: URL) -> Bool {
        return diagnose(url: url).count == 0
    }

    /// Write an index into an index file. Index is a dictionary where keys are
    /// strings and values are strings.
    ///
    func writeIndex(name: String, _ index: [String:String]) throws {
        // FIXME: We should not use id as a name as it can contain anything
        let encoder = JSONEncoder()
        var data: Data? = nil
        let url = rootURL.appendingPathComponent("\(name).json")

        data = try encoder.encode(index)
        try data!.write(to: url)
    }

    /// Read an index with given name.
    ///
    func readIndex(name: String) throws -> [String:String] {
        // FIXME: We should not use id as a name as it can contain anything
        let decoder = JSONDecoder()
        let url = rootURL.appendingPathComponent("\(name).json")
        
        let data = try Data(contentsOf: url)
        return try decoder.decode([String:String].self, from: data)
    }

    
    public func save(record: StoreRecord) throws {
        guard let type = record.type else {
            fatalError("Trying to write a record without a type: \(record)")
        }
        let fileName = String(record.id) + ".json"
        let url = urlForType(type: type).appendingPathComponent(fileName)
        let manager = FileManager.default
        
        try manager.createDirectory(at: urlForType(type: type),
                                    withIntermediateDirectories: true)
        var data: Data? = nil

        // We create a JSON serializable record – a dictionary.
        //
        var attributes: [String:Any] = [:]
        
        for key in record.keys {
            attributes[key] = record[key]?.anyValue()
        }
        
        let dict: [String:Any] = [
            "id": record.id,
            "type": type,
            "attributes": attributes
        ]
        
        // Serialize into JSON and write to a file
        try data = JSONSerialization.data(withJSONObject: dict)

        try data!.write(to: url)
        recordTypeMap[record.id] = type
        try writeIndex(name: "type_index", recordTypeMap)
    }

    /// Fetch object content from the object store
    ///
    public func fetch(id: ID) throws -> StoreRecord? {
        guard let type = recordTypeMap[id] else {
            return nil
        }
        let fileName = String(id) + ".json"
        let url = urlForType(type: type).appendingPathComponent(fileName)

        var data: Data? = nil

        // See `save()` for more information about encoding into JSON.
        //
        var dict: [String:Any] = [:]

        // Fetch data from a file.
        data = try Data(contentsOf: url)

        // Deserialize the JSON object. We are assuming the object be
        // a dictionary. We crash if the stored object is not a dictionary
        // as it is considered to be a corrupted store.
        //
        dict = try JSONSerialization.jsonObject(with: data!)
                        as! [String:Any]
        
        let id = dict["id"] as! String
        let decodedType = dict["type"] as! String
        
        guard type == decodedType else {
            fatalError("Decoded record '\(id)' type '\(decodedType)' is not as expected: '\(type)'")
        }
        
        let record = StoreRecord(type: type, id: id)
        // Reconstruct the object properties.
        // We assume for now that the PropertyValue is initializable from a
        // String.
        //
        for (key, value) in dict["attributes"] as! [String:Any] {
            record[key] = Value(any: value)
        }
        
        return record
    }
    
    /// Fetch all objects from the store. The fetched objects have ID associated
    /// but are not associated with a memory. It is up to the object memory
    /// to finalize the association.
    ///
    public func fetchAll(type: String) throws -> [StoreRecord] {
        var records: [StoreRecord] = []
        
        for item in recordTypeMap {
            if item.value == type {
                // TODO: What is source of truth? Map or filesystem?
                let record: StoreRecord = try fetch(id: item.key)!
                records.append(record)
            }
        }

        return records
    }


    /// Delete an object in the object store.
    ///
    public func delete(id: ID) throws {
        guard let type = recordTypeMap[id] else {
            fatalError("Trying to delete an object with unknown type: \(id)")
        }
        let fileName = String(id) + ".json"
        let url = urlForType(type: type).appendingPathComponent(fileName)

        let manager = FileManager()
        
        try manager.removeItem(at: url)
        recordTypeMap[id] = nil
    }
    
    
    /// Delete everything in the store.
    public func deleteAll() throws {
        for item in recordTypeMap {
            try delete(id: item.key)
        }
    }
}

