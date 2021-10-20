//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

import Foundation

public struct Issue: CustomStringConvertible {
    public enum Severity: String, Equatable {
        case info
        case warning
        case error
        
        /// `true` if the issue represents an error
        var isError: Bool { self == .error }
        
        /// `true` if the issue is an error or a warning
        var isRisky: Bool { self == .error || self == .warning }
    }
    
    /// Context
    public let context: String?
    /// Severity of the issue
    public let severity: Severity
    /// Issue message with detailed description what happened
    public let message: String
    /// Optional suggestion how to resolve the issue
    public let help: String?
    
    /// `true` if the issue represents an error
    public var isError: Bool { severity == .error }
    
    /// `true` if the issue is an error or a warning
    public var isRisky: Bool { severity == .error || severity == .warning }

    public init(_ severity: Severity, _ message: String, context: String?=nil, help: String?=nil){
        self.severity = severity
        self.message = message
        self.context = context
        self.help = help
    }
    
    public var description: String {
        let ctxStr = context.map { "\($0): " }  ?? ""
        let helpStr = help.map { " (\($0))" }  ?? ""
        return "[\(severity)] \(ctxStr)\(message)\(helpStr)"
    }
}

extension Issue: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(.error, stringLiteral)
    }
}


public final class IssueList {
    public var issues: [Issue]
    
    public required init(issues: [Issue]=[]) {
        self.issues = issues
    }
    
    /// Appends an error issue to the issue list.
    ///
    public func error(_ message: String, context: String?=nil, help: String?=nil){
        let issue = Issue(.error, message, context: context, help: help)
        self.issues.append(issue)
    }

    /// Appends a warning issue to the issue list.
    ///
    public func warning(_ message: String, context: String?=nil, help: String?=nil){
        let issue = Issue(.warning, message, context: context, help: help)
        self.issues.append(issue)
    }

    /// Appends an `info` issue to the issue list.
    ///
    public func info(_ message: String, context: String?=nil, help: String?=nil){
        let issue = Issue(.info, message, context: context, help: help)
        self.issues.append(issue)
    }
    
    /// List of all issues with `error` severity
    ///
    public var errors: [Issue] { issues.filter { $0.severity == .error } }

    /// List of all issues with `warning` severity
    ///
    public var warnings: [Issue] { issues.filter { $0.severity == .warning } }

    /// List of all issues with `info` severity
    ///
    public var infos: [Issue] { issues.filter { $0.severity == .info } }
    
    /// Test whether the list of issues contains at least one error issue. Returs
    /// `true` if there is an error issue.
    ///
    public var hasErrors: Bool { issues.contains { $0.isError} }

    /// Test whether the list of issues contains potential risky issues. Returs
    /// `true` if any of the issues is an error or a warning.
    ///
    public var hasRisks: Bool { issues.contains { $0.isRisky} }
}

extension IssueList: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral: Issue...) {
        self.init(issues: arrayLiteral)
    }
}

extension IssueList: RangeReplaceableCollection {
    public convenience init() {
        self.init(issues: [])
    }
    
    public var startIndex: Int { return issues.startIndex }
    public var endIndex: Int { return issues.endIndex }

    public subscript(key: Int) -> Issue {
        get { return issues[key] }
    }
    
    public func index(after: Int) -> Int {
        return issues.index(after:after)
    }
    public func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, C.Element == Issue {
        issues.replaceSubrange(subrange, with: newElements)
    }
}
