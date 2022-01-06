//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/21.
//

import DotWriter

/// Extension for writing GraphViz .dot files from the graph memory.
///
public extension GraphMemory {
    func writeDot(path: String, name: String) {
        let writer = DotWriter(path: path, name: name, type: .directed)
        
        for node in nodes {
            writer.writeNode("\(node.id ?? 0)")
        }
        for link in links {
            writer.writeEdge(from:"\(link.origin.id ?? 0)",
                             to:"\(link.target.id ?? 0)")
        }
        writer.close()
    }
}
 
public class DotExporter {
    let path: String
    let name: String
    let labelAttribute: String?
    
    public init(path: String, name: String, labelAttribute: String? = nil) {
        self.path = path
        self.name = name
        self.labelAttribute = labelAttribute
    }
    
    public func export(nodes: [Node], links: [Link]) {
        let writer = DotWriter(path: path, name: name, type: .directed)
        
        for node in nodes {
            let label: String
            if let attribute = labelAttribute {
                label = node[attribute]?.stringValue() ?? ""
            }
            else {
                label = node.id.map { String($0) } ?? "(no ID)"
            }
            writer.writeNode(label)
        }
        for link in links {
            writer.writeEdge(from:"\(link.origin.id ?? 0)",
                             to:"\(link.target.id ?? 0)")
        }
        writer.close()
    }
}
