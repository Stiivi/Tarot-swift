//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

import Foundation

/// An object representing a ``Loader`` issue.
///
public struct Issue: CustomStringConvertible {
    
    /// Severity of the issue.
    public enum Severity: String, Equatable {
        
        /// Not a real issue, but we want user to know about what is going on
        case info
        /// An issue of mild concern that might not require a treatment.
        case warning
        /// An issue of high concern that requires treatment.
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

    /// Create an issue.
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

public extension Array where Element == Issue {
    /// Appends an error issue to the issue list.
    ///
    mutating func error(_ message: String, context: String?=nil, help: String?=nil){
        let issue = Issue(.error, message, context: context, help: help)
        self.append(issue)
    }

    /// Appends a warning issue to the issue list.
    ///
    mutating func warning(_ message: String, context: String?=nil, help: String?=nil){
        let issue = Issue(.warning, message, context: context, help: help)
        self.append(issue)
    }

    /// Appends an `info` issue to the issue list.
    ///
    mutating func info(_ message: String, context: String?=nil, help: String?=nil){
        let issue = Issue(.info, message, context: context, help: help)
        append(issue)
    }
    
    /// List of all issues with `error` severity
    ///
    var errors: [Issue] { filter { $0.severity == .error } }

    /// List of all issues with `warning` severity
    ///
    var warnings: [Issue] { filter { $0.severity == .warning } }

    /// List of all issues with `info` severity
    ///
    var infos: [Issue] { filter { $0.severity == .info } }
    
    /// Test whether the list of issues contains at least one error issue. Returs
    /// `true` if there is an error issue.
    ///
    var hasErrors: Bool { contains { $0.isError} }

    /// Test whether the list of issues contains potential risky issues. Returs
    /// `true` if any of the issues is an error or a warning.
    ///
    var hasRisks: Bool { contains { $0.isRisky} }

}

public typealias IssueList = Array<Issue>
