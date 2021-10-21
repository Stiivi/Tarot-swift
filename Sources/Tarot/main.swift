//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//
import GraphMemory

// Main

let DATA_PATH = "/Users/stefan/Documents/Data Cards/Cards of Data Governance 2021"

let FILE_MAP = [
    "cards": "cards-main.csv",
    "links": "relationships-main.csv",
    "stats": "types-stats.csv",
]


func main() throws {
    // try loadModel(DATA_PATH, fileMap: FILE_MAP)
    print("Loading model...")
    do {
        try loadModel(DATA_PATH, fileMap: FILE_MAP)
    }
    catch ImportError.validationError(let issues) {
        for issue in issues {
            print(issue)
        }
    }
    print("Done.")
}

try main()
