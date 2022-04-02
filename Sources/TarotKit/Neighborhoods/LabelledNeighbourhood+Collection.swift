//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/04/2022.
//

import Foundation

extension LabelledNeighbourhood: Sequence {
    public typealias Iterator = Array<Node>.Iterator
    public func makeIterator() -> Iterator {
        return nodes.makeIterator()
    }
}
