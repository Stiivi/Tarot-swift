//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/5.
//

import Foundation


/*

 Design notes:
 
 Space
 - memory
 - model
 
 - collections
    - custom created collections of nodes of assorted type
 - perspectives
    - custom collections of main nodes put into context of supportive nodes
 - views/projections/filters
    - 
 
 
 */


// TODO: Add semantics to connections, such as "name"
// TODO: Add removal of multiple nodes

/// Space represents a problem or a project. Space associates a graph memory
/// with its model as a semantics.
///
public class Space {
    
    /// Graph memory containing objects within the space.
    public let memory: GraphMemory
    
    /// Semantics of the graph memory.
    public let model: Model
    
    public init(model: Model) {
        memory = GraphMemory()
        self.model = model
    }
}
