//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/30.
//

import Records

public protocol GraphDelegate {
    /// Function called when a node is added to the graph.
    func graph(_ graph: Graph, didAdd: Node)
    
    /// Function called when a node is removed from the graph.
    func graph(_ graph: Graph, didRemove: Node)
    
    /// Function called when a link is created in the graph.
    func graph(_ graph: Graph, didConnect: Link)
    
    /// function called when a link is removed from the graph.
    func graph(_ graph: Graph, didDisconnect: Link)
    
    /// Function called when an attribute is set.
    func graph(_ graph: Graph, didSet: Object, attribute: String, value: Value)
    
    /// Function called when an attribute is removed.
    func graph(_ graph: Graph, didUnset: Object, attribute: String)
}

extension GraphDelegate {
    /// Function called when a node is added to the graph.
    func graph(_ graph: Graph, didAdd: Node) {
        /* do nothing */
    }
    
    /// Function called when a node is removed from the graph.
    func graph(_ graph: Graph, didRemove: Node)  {
        /* do nothing */
    }
    
    /// Function called when a link is created in the graph.
    func graph(_ graph: Graph, didConnect: Link)  {
        /* do nothing */
    }
    
    /// function called when a link is removed from the graph.
    func graph(_ graph: Graph, didDisconnect: Link)   {
        /* do nothing */
    }
    
    /// Function called when an attribute is set.
    func graph(_ graph: Graph, didSet: Object, attribute: String, value: Value)  {
        /* do nothing */
    }
    
    /// Function called when an attribute is removed.
    func graph(_ graph: Graph, didUnset: Object, attribute: String)  {
        /* do nothing */
    }
}

class GraphChange {
    let type: GraphChangeType
    
    init(_ type: GraphChangeType) {
        self.type = type
    }
}

enum GraphChangeType: String {
    case didAddNode
    case didRemoveNode
    case didConnect
    case didDisconnect
    case didSet
    case didUnset
}

