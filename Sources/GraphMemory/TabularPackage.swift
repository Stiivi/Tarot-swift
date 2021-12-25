//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/6.
//

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
public struct TabularPackage: Decodable {
    let label: String
    let nodes: [NodeResourceDescription]
    let links: [LinkResourceDescription]
    let fieldMap: FieldMap?
}

