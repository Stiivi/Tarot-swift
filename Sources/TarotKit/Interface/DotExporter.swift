//
//  File.swift
//
//
//  Created by Stefan Urbanek on 2021/10/21.
//

// NOTE: This is simple one-use exporter.
// TODO: Make this export to a string and make it export by appending content.

/// Object that exports nodes and links into a [GraphViz](https://graphviz.org)
/// dot language file.
public class DotExporter {
    /// Path of the file to be exported to.
    let path: String

    /// Name of the graph in the output file.
    let name: String
    
    /// Attribute of nodes that will be used as a node label in the output.
    /// If not set then the node ID will be used.
    ///
    let labelAttribute: String?
    
    /// Creates a GraphViz DOT file exporter.
    ///
    /// - Parameters:
    ///     - path: Path to the file where the output is written
    ///     - name: Name of the graph in the output
    ///     - labelAttribute: Attribute of exported nodes that will be used
    ///     as a label of nodes in the output. If not set then node ID will be
    ///     used.
    ///
    public init(path: String, name: String, labelAttribute: String? = nil) {
        self.path = path
        self.name = name
        self.labelAttribute = labelAttribute
    }
    
    /// Export nodes and links into the output.
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
