//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 30/12/2021.
//

import Records

extension GraphMemory {
    @discardableResult
    public func connect(from origins: [Node], to target: Node, attributes: [String:Value]=[:]) -> [Link] {
        let links: [Link]
        
        links = origins.map { origin in
            connect(from: origin, to: target, attributes: attributes)
        }
        
        return links
    }
    
    @discardableResult
    public func connect(from origin: Node, to targets: [Node], attributes: [String:Value]=[:]) -> [Link] {
        let links: [Link]
        
        links = targets.map { target in
            connect(from: origin, to: target, attributes: attributes)
        }
        
        return links
    }

}
