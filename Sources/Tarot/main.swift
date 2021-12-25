//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//
import GraphMemory
import Foundation

let dataURL = URL(fileURLWithPath: "/Users/stefan/Documents/Data Cards/Cards of Data Governance 2021",
                  isDirectory: true)

func main() throws {
    let tool: TarotTool
    
    do {
        tool = try TarotTool(dataURL: dataURL)
    }
    catch ImportError.validationError(let issues) {
        for issue in issues {
            print(issue)
        }
        fatalError("Validation errors found. Abandoning.")
    }
    
    // Validate and load data
    print("Loading data...")
    tool.writeDOT()
   
    // print("Generating PDFs...")
    // tool.makeCardsPDF()
    // FIXME: VALIDATE NODES!!!!
    // FIXME: VALIDATE MODEL CONFORMANCE!!!
}

try main()
