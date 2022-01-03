//
//  CSVReader.swift
//
//  Created by Stefan Urbanek on 2021/8/31.
//


/// Set of options to read CSV files.
///
public class CSVReadingOptions: Decodable {
    
    /// Record delimiter character. Default is a comma `,`.
    ///
    public let delimiter: Character
    
    public init(delimiter: Character=",") {
        self.delimiter = delimiter
    }

    enum CodingKeys: CodingKey {
        case delimiter
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let str = try values.decode(String.self, forKey: .delimiter)
        // TODO: Handle error here
        delimiter = str.first!
    }
}

/// CSVReader reads a string ctonaining a comma separated values and then
/// generates list of rows where a row is a list of values. All values are
/// string values.
///
/// CSV reading is according to RFC4280.
///
class CSVReader: Sequence, IteratorProtocol {
    public enum Token: Equatable {
        case empty
        case value(String)
        case recordSeparator
        case fieldSeparator
    }

    enum State {
        case newField
        case inField
        case inQuote
    }
    
    var options: CSVReadingOptions
    
    var iterator: String.Iterator
    var currentChar: Character?
    var state: State = .newField
    public var tokenText: String = ""
    
    init(_ iterator: String.Iterator, options: CSVReadingOptions=CSVReadingOptions()) {
        self.iterator = iterator
        currentChar = self.iterator.next()
        self.options = options
    }
    
    init(_ string: String = "", options: CSVReadingOptions=CSVReadingOptions()) {
        iterator = string.makeIterator()
        currentChar = iterator.next()
        self.options = options
    }
    
    var atEnd: Bool { currentChar == nil }
    
    /// Advance the reader and optionally append the current chacter into the
    /// token text.
    ///
    func advance(append: Bool=true) {
        if let char = currentChar {
            if append {
                tokenText.append(char)
            }
        }
        currentChar = iterator.next()
    }
    
    /// Get a next CSV token.
    ///
    func nextToken() -> Token {
        tokenText.removeAll()
        
        if atEnd {
            return .empty
        }
        else if currentChar?.isNewline ?? false {
            advance()
            return .recordSeparator
        }
        else if currentChar == options.delimiter {
            advance()
            return .fieldSeparator
        }
        else if currentChar == "\"" {
            advance(append:false)
            var gotQuote: Bool = false
            
            while !atEnd {
                if currentChar == "\"" {
                    if gotQuote {
                        advance()
                        gotQuote = false
                    }
                    else {
                        // Maybe end, maybe escape, we don't append
                        advance(append:false)
                        gotQuote = true
                    }
                }
                else { // any character except quote
                    if gotQuote {
                        if currentChar == options.delimiter {
                            // We got a field separator after a quote
                            break
                        }
                        else if currentChar?.isNewline ?? false {
                            // We got a record separator after a quote
                            break
                        }
                        else {
                            // We eat anything after the closing quote
                            // Note: This behaviour was observed with both
                            // MS Excel and with Number.
                            gotQuote = false
                            advance()
                        }
                    }
                    else { // got no quote
                        advance()
                    }
                }
            }
            return .value(tokenText)
        }
        else {
            while !atEnd {
                if currentChar == options.delimiter {
                    break
                }
                else if currentChar?.isNewline ?? false {
                    break
                }
                advance()
            }
            return .value(tokenText)
        }
    }
    
    /// Get the next row in the CSV source. A row is a list of string values.
    /// If the reader is at the end then `nil` is returned.
    ///
    func next() -> [String]? {
        var row: [String] = []
        
        if atEnd {
            return nil
        }
        
        var hadValue = false
        
        loop: while !atEnd {
            // Whether the last token wa a value
            switch nextToken() {
            case .empty:
                break loop
            case .value(let text):
                row.append(text)
                hadValue = true
            case .fieldSeparator:
                if !hadValue {
                    // we did not have a value, we append an empty string
                    row.append("")
                }
                hadValue = false
            case .recordSeparator:
                if !hadValue {
                    row.append("")
                }
                break loop
            }
        }
        return row
    }
}

