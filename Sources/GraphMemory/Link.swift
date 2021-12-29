//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

/// Link represents a graph edge - conection between two nodes.
///
public class Link: Object {
    public let origin: Node
    public let target: Node
    
    init(id: OID, origin: Node, target: Node) {
        self.origin = origin
        self.target = target
        super.init(id: id)
    }
}

