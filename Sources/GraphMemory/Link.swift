//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

/// Link represents a graph edge - conection between two nodes.
///
public class Link: Object {
    let origin: Node
    let target: Node
    
    // FIXME: This is scaffolding
    var name: String {
        return self["name"]!.stringValue()!
    }
    
    init(id: OID, origin: Node, target: Node, at name: String) {
        self.origin = origin
        self.target = target
        super.init(id: id)
        // FIXME: This is scaffolding
        self["name"] = .string(name)
    }
}

