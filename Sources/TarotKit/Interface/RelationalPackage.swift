//
//  RelationalSource.swift
//  
//
//  Created by Stefan Urbanek on 07/01/2022.
//

import Foundation
import Records
import System


/// Description of a relational resource containing nodes.
///
public struct NodeRelation: Codable {
    // Name of the relation.
    public let name: String
    
    /// Name of the relational resource containing records describing nodes.
    /// If not provided then it will be the same as the name.
    public let resource: String

    /// Name of a field that contains a unique key identifying the record.
    /// Default value is `id`.
    ///
    public let primaryKey: String

    /// A dictionary of fields that refer to other relational node resources.
    /// Keys are field names in this node resource and values are names of
    /// refered resources. The value of a field in this resource will be matched
    /// with a value of a field in the target resource.
    ///
    public let foreignKeys: [String:String]
    
    public init(name: String, primaryKey: String?=nil, resource: String?=nil,
                foreignKeys: [String:String]?=nil) {
        self.name = name
        self.resource = resource ?? name
        self.primaryKey = primaryKey ?? "id"
        self.foreignKeys = foreignKeys ?? [:]
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let resource = try container.decodeIfPresent(String.self, forKey: .resource)
        let primaryKey = try container.decodeIfPresent(String.self, forKey: .primaryKey)
        let foreignKeys = try container.decodeIfPresent([String:String].self, forKey: .foreignKeys)

        self.init(name: name,
                  primaryKey: primaryKey,
                  resource: resource ?? name,
                  foreignKeys: foreignKeys)
    }

}


/// Description of a relational resource containing links.
///
public struct LinkRelation: Codable {
    /// Name of the relation.
    public let name: String
    /// Name of the relational resource containing records that describe links.
    /// If not provided then it will be the same as the name.
    public let resource: String
    /// Name of a field that contains link origin key. Default value is `origin`
    public let originKey: String
    /// Name of a record set that contains origin nodes.
    public let originRelation: String
    /// Name of a field that contains link target key. Default value is `target`
    public let targetKey: String
    /// Name of a resource that contains target nodes. If not specified then
    /// the same resource as the origin resource is assumed.
    public let targetRelation: String

    public init(name: String, resource: String?=nil, originKey: String?=nil, originRelation: String,
                targetKey: String?=nil, targetRelation: String?=nil) {
        self.name = name
        self.resource = resource ?? name
        self.originKey = originKey ?? "origin"
        self.originRelation = originRelation
        self.targetKey = targetKey ?? "target"
        self.targetRelation = targetRelation ?? originRelation
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let resource = try container.decodeIfPresent(String.self, forKey: .resource)
        let originKey = try container.decodeIfPresent(String.self, forKey: .originKey)
        let originRelation = try container.decode(String.self, forKey: .originRelation)
        let targetKey = try container.decodeIfPresent(String.self, forKey: .targetKey)
        let targetRelation = try container.decodeIfPresent(String.self, forKey: .targetRelation)

        self.init(name: name,
                  resource: resource ?? name,
                  originKey: originKey,
                  originRelation: originRelation,
                  targetKey: targetKey,
                  targetRelation: targetRelation)
    }

}

/// Source of a graph in a form of relational entities, such as relational
/// database tables.
///
/// Relational entities are represented by `RecordSet` and it might contain
/// list of nodes or list of links.
///
public class RelationalPackageInfo: Decodable {
    /// List of sources containing nodes
    ///
    public let nodes: [NodeRelation]
    /// List of sources containing links
    ///
    public let links: [LinkRelation]

    /// Options for reading the resources
    public let readingOptions: CSVReadingOptions?

    /// Path to the resources. If not provided then the package path is used.
    public let resourcesPath: FilePath?

}

/// Relational data package.
///
/// This class describes a collection of resources and metadata about a graph memory
/// stored in files.
///
/// Package is a directory. The content of the directory is:
///
/// - `info.json`: information about the package (required)
/// - `model.json`: model of the package (optional)
/// - resource files containing nodes
/// - resource files containing links
///
/// Currently only tabular data files (CSV) are supported as resource files.
///
public class RelationalPackage {
    public let packageRoot: URL

    public let info: RelationalPackageInfo
    
    /// List of resources containing nodes.
    public var nodeRelations: [NodeRelation] { info.nodes }
    
    /// List of resources containing links.
    public var linkRelations: [LinkRelation] { info.links }
    
    /// Options for reading the resources
    public var readingOptions: CSVReadingOptions? { info.readingOptions }
    
    /// Base URL for resources.
    ///
    public var resourcesURL: URL {
        if let path = info.resourcesPath {
            if path.isRelative {
                let url: URL
                url = packageRoot.appendingPathComponent(path.string,
                                                         isDirectory: true)
                return url
            }
            else {
                return URL(fileURLWithPath: path.string, isDirectory: true)
            }
        }
        else {
            return packageRoot
        }
    }
    
    /// Returns URL for a resource containing the model.
    ///
    public var modelURL: URL {
        return packageRoot.appendingPathComponent("model.json")
    }
    
    /// Create a package from given URL.
    ///
    /// The package is a directory with at least one file: `info.json`. The
    /// typical package structure is:
    ///
    /// ```
    /// PACKAGE/
    ///     info.json
    ///     model.json
    ///     nodes.csv
    ///     links.csv
    /// ```
    ///
    public init?(url: URL) {
        packageRoot = url
        
        let infoURL = packageRoot.appendingPathComponent("info.json")
        
        do {
            let json = try Data(contentsOf: infoURL)
            info = try JSONDecoder().decode(RelationalPackageInfo.self, from: json)
        }
        catch {
            return nil
        }
    }
    
    /// Return a full URL for a resource. The method does not check whether the
    /// resource exists or not.
    ///
    public func url(forResource resource: String) -> URL {
        return resourcesURL.appendingPathComponent(resource)
    }

}

