//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//
import GraphMemory
import Foundation

// Main

let DATA_PATH = "/Users/stefan/Documents/Data Cards/Cards of Data Governance 2021"

let FILE_MAP = [
    "cards": "cards-main.csv",
    "links": "relationships-main.csv",
    "stats": "types-stats.csv",
]

func loadModel(url: URL) throws -> Model {
    let json = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    let model = try decoder.decode(Model.self,from: json)
    return model
}
    
func main() throws {
    let space = GraphMemory()
    
    print("Load model...")
    let modelURL =  Bundle.module_WORKAROUND.url(forResource: "model", withExtension: "json")

    let model = try loadModel(url: modelURL!)
    
    print("Loading data...")
    do {
        try loadData(space, DATA_PATH, fileMap: FILE_MAP)
    }
    catch ImportError.validationError(let issues) {
        for issue in issues {
            print(issue)
        }
    }
    space.writeDot(path: "/tmp/graph.dot", name: "cards")
    print("Done.")
}

try main()
