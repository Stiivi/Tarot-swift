//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 30/12/2021.
//

extension GraphMemory {
    /// Filters nodes based on the predicate
    ///
    public func filterNodes(predicate: ObjectPredicate) -> [Node] {
        return nodes.filter { predicate.matches($0) }
    }

    /// Filters links based on the predicate
    ///
    public func filterLinks(predicate: ObjectPredicate) -> [Link] {
        return links.filter { predicate.matches($0) }
    }

}
