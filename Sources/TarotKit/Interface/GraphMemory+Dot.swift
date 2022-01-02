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
