//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 20/01/2022.
//

import Records

/// Type of the neighbourhood. Specifies the intended use of the
/// neighbourhood, how it should be managed and which attributes are
/// considered while using it.
///
public enum NeighbourhoodType {
    /// Non-specified neighbourhood type. Only information we have is
    /// the link selector.
    case any
    
    /// Type of a neighbourhood that contains an ordered collection of links.
    /// See ``IndexedCollection`` for more information.
    case indexed

    /// Type of a neighbourhood that contains a mapping between a key and a
    /// node.
    /// See ``KeyedCollection`` for more information.
    case keyed
    
    /// Type of a neighbourhood that contains only one node.
    ///
    case one
}

/// Projection of a node that describes a neighbourhood.
///
/// `NeighbourhoodDescription` gives a meaning to a particular kind of a
/// neighbourhood that nodes might be surrounded by.
///
///
public class NeighbourhoodTrait: BaseNodeProjection {
    // TODO: Write here how the name is used.
    /// Name of the neighbourhood.
    ///
    public var name: String? { representedNode["name"]?.stringValue() }
    
    /// Type of the neighbourhood. Specifies the intended use of the
    /// neighbourhood, how it should be managed and which attributes are
    /// considered while using it.
    ///
    public var type: NeighbourhoodType {
        get {
            switch representedNode["type"] {
            case "indexed": return .indexed
            case "keyed": return .keyed
            case "one": return .one
            case "any": return .any
            default: return .any
            }
        }
        set(type) {
            switch type {
            case .indexed: representedNode["type"] = "indexed"
            case .keyed: representedNode["type"] = "keyed"
            case .one: representedNode["type"] = "one"
            case .any: representedNode["type"] = "any"
            }
        }
    }

    
    // Selector
    /// Attribte used as a label for the links in the neighbourhood.
    /// See``LinkSelector`` for more information.
    ///
    public var labelAttribute: String {
        // TODO: Use DefaultLinkLabelAttribute
        representedNode["label_attribute"]?.stringValue() ?? DefaultLinkLabelAttribute
    }

    /// Value of a label attribute that specifies the neighbourhood.
    /// See``LinkSelector`` for more information.
    ///
    public var label: Value {
        representedNode["label"] ?? DefaultNeighbourhoodItemLabel
    }

    /// Direction in which the links are considered towards the represented
    /// object. Values are strings and can be either `outgoing` or `incoming`.
    ///
    /// See``LinkSelector`` for more information.
    ///
    public var direction: LinkDirection? {
        switch representedNode["direction"] {
        case "outgoing": return .outgoing
        case "incoming": return .incoming
        default: return nil
        }
    }


    /// A link selector derived from the neighbourhood description.
    ///
    public var selector: LinkSelector {
        return LinkSelector(label,
                            direction: direction ?? .outgoing,
                            labelAttribute: labelAttribute)
    }
    
    public var indexAttribute: String? { representedNode["index_attribute"]?.stringValue() }
    public var keyAttribute: String? { representedNode["key_attribute"]?.stringValue() }
    
    // TODO: I
    public func neighbourhood(in node: Node) -> LabelledNeighbourhood {
        switch type {
        case .any: return LabelledNeighbourhood(node, selector: selector)
        case .indexed: return IndexedNeighbourhood(node, selector: selector, indexAttribute: indexAttribute ?? "index")
        case .keyed: return KeyedNeighbourhood(node, selector: selector, keyAttribute: keyAttribute ?? "key")
        case .one: return NeighbourhoodOfOne(node, selector: selector)
        }
    }

    public func indexedCollection(for node: Node) -> IndexedNeighbourhood {
        return IndexedNeighbourhood(node, selector: selector, indexAttribute: indexAttribute ?? "index")
    }

    public func keyedCollection(for node: Node) -> KeyedNeighbourhood {
        return KeyedNeighbourhood(node, selector: selector, keyAttribute: keyAttribute ?? "key")
    }
}

