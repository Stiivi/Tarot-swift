//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/30.
//

import Foundation

enum __GraphChangeType {
    case addNode
    case removeNode
    case connect
    case disconnect
    case setAttribute
    case unsetAttribute
}

class Transaction {
}
