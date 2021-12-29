//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/6.
//
import Foundation
import System
import Records

/// Description of a link resource.
///
/// The ``resource`` property refers to a resource, for example a file, the
/// links are stored. ``namespace`` specifies in which namespace the
/// references to objects will be resolved. If not provided, then default shared
/// namespace will be used.
///
/// Optional ``label`` is used for user-facing descriptive label of the resource that
/// might be friendlier and more informative than the resource name.
///
public struct LinkResourceDescription: Codable {
    let label: String?
    let resource: String
    let namespace: String?

    public init(resource: String, namespace: String?=nil, label: String?=nil) {
        self.resource = resource
        self.namespace = namespace
        self.label = label
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let label = try container.decodeIfPresent(String.self, forKey: .label)
        let resource = try container.decode(String.self, forKey: .resource)
        let namespace = try container.decodeIfPresent(String.self, forKey: .namespace)

        self.init(resource: resource, namespace: namespace, label: label )
    }
}

/// Description of a node resource.
///
/// The ``resource`` property refers to a resource, for example a file, the
/// nodes are stored. ``namespace`` specifies in which namespace the
/// objects keys will be stored and later resolved when loading links.
/// If not provided, then default shared namespace will be used.
///
/// Optional ``label`` is used for user-facing descriptive label of the resource that
/// might be friendlier and more informative than the resource name.
///
public struct NodeResourceDescription: Codable {
    let label: String?
    let resource: String
    
    // FIXME: Rename to `tag` with free interpretation of the semantic layer
    let trait: String?
    let namespace: String?
    
    public var description: String {
        var desc: String
        if let label = label {
            desc = "\(label) in \(resource)"
        }
        else {
            desc = resource
        }
        
        if let trait = trait {
            desc += "as \(trait)"
        }
        
        return desc
    }
}

/// Description of a package with tabular data, typically CSV files, which
/// contain nodes and links.
///
public class PackageInfo: Decodable {
    /// Human-readable label of the package.
    let label: String
    
    /// List of resources containing nodes.
    let nodes: [NodeResourceDescription]
    
    /// List of resources containing links.
    let links: [LinkResourceDescription]
    
    /// Mapping of field names in the tabular resources.
    let fieldMap: FieldMap?
    
    /// Path to the resources. If not provided then the package path is used.
    let resourcesPath: FilePath?
    
    /// Options for reading the resources
    let resourceOptions: CSVReadingOptions?
    
    enum CodingKeys: CodingKey {
        case label
        case nodes
        case links
        case fieldMap
        case resourcesPath
        case resourceOptions
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decode(String.self, forKey: .label)
        nodes = try values.decode([NodeResourceDescription].self, forKey: .nodes)
        links = try values.decode([LinkResourceDescription].self, forKey: .links)
        fieldMap = try values.decodeIfPresent(FieldMap.self, forKey: .fieldMap)
        resourceOptions = try values.decodeIfPresent(CSVReadingOptions.self, forKey: .resourceOptions)
        
        let path = try values.decode(String.self, forKey: .resourcesPath)
        resourcesPath = FilePath(path)
    }
}

/// Graph Memory file package.
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
public class Package {
    let packageRoot: URL

    let info: PackageInfo
    
    /// Human-readable label of the package.
    var label: String { info.label }
    
    /// List of resources containing nodes.
    var nodes: [NodeResourceDescription] { info.nodes }
    
    /// List of resources containing links.
    var links: [LinkResourceDescription] { info.links }
    
    /// Mapping of field names in the tabular resources.
    var fieldMap: FieldMap? { info.fieldMap }
        
    /// Options for reading the resources
    var resourceOptions: CSVReadingOptions? { info.resourceOptions }
    
    /// Base URL for resources.
    ///
    var resourcesURL: URL {
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
    public init(url: URL) throws {
        packageRoot = url
        
        let infoURL = packageRoot.appendingPathComponent("info.json")
        let json = try Data(contentsOf: infoURL)
        info = try JSONDecoder().decode(PackageInfo.self, from: json)
    }
    
    /// Return a full URL for a resource. The method does not check whether the
    /// resource exists or not.
    ///
    public func url(forResource resource: String) -> URL {
        return resourcesURL.appendingPathComponent(resource)
    }

}

