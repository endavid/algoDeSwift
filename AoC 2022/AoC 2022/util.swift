//
//  util.swift
//  AoC 2022
//
//  Created by En David on 02/12/2022.
//

import Foundation

extension Array {
    // https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    func substring(from: Int, to: Int) -> String {
        let a = index(from: from)
        let b = index(from: to)
        return String(self[a..<b])
    }
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
}

enum CLIError: LocalizedError {
    case noInputFile
    case fileDoesNotExist(name: String)
    case cantParseDay(name: String)
    
    var errorDescription: String? {
        switch self {
        case .noInputFile:
            return "No input file"
        case .fileDoesNotExist(let f):
            return "\(f) does not exist"
        case .cantParseDay(let name):
            return "Can't parse day in \(name). File name should start with 'dayXXX'"
        }
    }
}

func parseCLI() throws -> (day: Int, lines: [String], output: String?) {
    if CommandLine.arguments.count == 1 {
        throw CLIError.noInputFile
    }
    let filename = CommandLine.arguments[1]
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: filename) {
        throw CLIError.fileDoesNotExist(name: filename)
    }
    let fileURL = URL(fileURLWithPath: filename)
    let name = fileURL.lastPathComponent
    if !name.starts(with: "day") {
        throw CLIError.cantParseDay(name: name)
    }
    let dayPart = String(name.split(separator: "_").first ?? "day0")
    guard let day = Int(dayPart.substring(from: 3)) else {
        throw CLIError.cantParseDay(name: name)
    }
    let contents = try String(contentsOfFile: filename)
    var lines = contents.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
    while lines.last?.isEmpty ?? false {
        // we've kept empty lines, but remove the empty lines at the end
        let _ = lines.popLast()
    }
    let output = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : nil
    return (day, lines, output)
}
