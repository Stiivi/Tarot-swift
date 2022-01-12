//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 03/01/2022.
//

import Foundation
import Records

public class TreeItem {
    
}

/*
 
 Tree relationships:
 
 */

/// View of a node representing a hierarchical structure.
///
public class Tree: NodeProjection {
    /// Node representing the collection
    public var representedNode: Node
    
    // TODO: These should follow what is specified in the tree root
    public var linkOrderAttribute: String? { representedNode["linkOrderAttribute"]?.stringValue() }
    public var linkLabel: String { representedNode["linkLabel"]?.stringValue() ?? "child" }

    
    public let parent: Tree?
    // TODO: NULLS FIRST/LAST
    
    /// Creates a collection rooted in `node`.
    ///
    public init(_ node: Node, parent: Tree? = nil) {
        self.representedNode = node
        self.parent = parent
    }
    
    /// List of collection items.
    ///
//    var children: [Tree] {
//        let children = nodes.map {
//            Tree($0.target)
//        }
//        return children
//    }
//    
//    /// List of all children nodes.
//    var allChildren: [Tree] {
//        return children.flatMap { $0.allChildren }
//    }
//    
//    var depth: Int {
//        if let parent = parent {
//            return parent.depth + 1
//        }
//        else {
//            return 0
//        }
//    }
}
