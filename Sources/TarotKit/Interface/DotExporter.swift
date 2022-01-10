//
//  File.swift
//
//
//  Created by Stefan Urbanek on 2021/10/21.
//

import DotWriter

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
                label = node[attribute]?.stringValue()
                        ?? node.id.map { String($0) }
                        ?? "(no label)"
            }
            else {
                label = node.id.map { String($0) } ?? "(no ID)"
            }

            let attributes: [String:String] = [
                "label": label
            ]
            
            let id = "\(node.id ?? 0)"
            writer.writeNode(id, attributes: attributes)
        }
        
        for link in links {
            writer.writeEdge(from:"\(link.origin.id ?? 0)",
                             to:"\(link.target.id ?? 0)")
        }
        writer.close()
    }
}
