//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/30.
//

import Records

public protocol GraphMemoryDelegate {
    /// Function called when a node is added to the graph.
    func graph(_ graph: GraphMemory, didAdd: Node)
    
    /// Function called when a node is removed from the graph.
    func graph(_ graph: GraphMemory, didRemove: Node)
    
    /// Function called when a link is created in the graph.
    func graph(_ graph: GraphMemory, didConnect: Link)
    
    /// function called when a link is removed from the graph.
    func graph(_ graph: GraphMemory, didDisconnect: Link)
    
    /// Function called when an attribute is set.
    func graph(_ graph: GraphMemory, didSet: Object, attribute: String, value: Value)
    
    /// Function called when an attribute is removed.
    func graph(_ graph: GraphMemory, didUnset: Object, attribute: String)
}

extension GraphMemoryDelegate {
    /// Function called when a node is added to the graph.
    func graph(_ graph: GraphMemory, didAdd: Node) {
        /* do nothing */
    }
    
    /// Function called when a node is removed from the graph.
    func graph(_ graph: GraphMemory, didRemove: Node)  {
        /* do nothing */
    }
    
    /// Function called when a link is created in the graph.
    func graph(_ graph: GraphMemory, didConnect: Link)  {
        /* do nothing */
    }
    
    /// function called when a link is removed from the graph.
    func graph(_ graph: GraphMemory, didDisconnect: Link)   {
        /* do nothing */
    }
    
    /// Function called when an attribute is set.
    func graph(_ graph: GraphMemory, didSet: Object, attribute: String, value: Value)  {
        /* do nothing */
    }
    
    /// Function called when an attribute is removed.
    func graph(_ graph: GraphMemory, didUnset: Object, attribute: String)  {
        /* do nothing */
    }
}

public class GraphChange {
    let type: GraphChangeType
    
    init(_ type: GraphChangeType) {
        self.type = type
    }
}

public enum GraphChangeType: String {
    case didAddNode
    case didRemoveNode
    case didConnect
    case didDisconnect
    case didSet
    case didUnset
}

