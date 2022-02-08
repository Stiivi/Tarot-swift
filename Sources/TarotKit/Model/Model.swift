//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 07/02/2022.
//

import Records

/// Node that represents an attribute description.
public class Model: BaseNodeProjection {
    public var attributes: IndexedCollection {
        return IndexedCollection(representedNode,
                                 selector:LinkSelector("attribute"))
    }
}
