//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/30.
//

import Foundation

import Records

public enum GraphChange: Equatable {
    case addNode(Node)
    case removeNode(Node)
    case connect(Link)
    case disconnect(Link)
    case setAttribute(Object, AttributeKey, Value)
    case unsetAttribute(Object, AttributeKey)
    
    public static func ==(lhs: GraphChange, rhs: GraphChange) -> Bool {
        switch (lhs, rhs) {
        case let (.addNode(lnode), .addNode(rnode)):
            return lnode == rnode
        case let (.removeNode(lnode), .removeNode(rnode)):
            return lnode == rnode
        case let (.connect(llink), .connect(rlink)):
            return llink == rlink
        case let (.disconnect(llink), .disconnect(rlink)):
            return llink == rlink
        case let (.setAttribute(lobj, lattr, lvalue), .setAttribute(robj, rattr, rvalue)):
            return lobj == robj && lattr == rattr && lvalue == rvalue
        case let (.unsetAttribute(lobj, lattr), .unsetAttribute(robj, rattr)):
            return lobj == robj && lattr == rattr
        default: return false
        }
    }
}

// TODO: Unused
enum GraphChangeType: String {
    case addNode
    case removeNode
    case connect
    case disconnect
    case setAttribute
    case unsetAttribute
}
