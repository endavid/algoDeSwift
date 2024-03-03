//
//  Util.swift
//  AoC 2023
//
//  Created by David Gavilan Ruiz on 03/03/2024.
//

import Foundation

extension Array {
    // https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    // https://stackoverflow.com/a/34299723
    /**
     Returns a new array with the first elements up to specified distance being shifted to the end of the collection. If the distance is negative, returns a new array with the last elements up to the specified absolute distance being shifted to the beginning of the collection.

     If the absolute distance exceeds the number of elements in the array, the elements are not shifted.
     */
    func shift(withDistance distance: Int = 1) -> Array<Element> {
        let offsetIndex = distance >= 0 ?
            self.index(startIndex, offsetBy: distance, limitedBy: endIndex) :
            self.index(endIndex, offsetBy: distance, limitedBy: startIndex)

        guard let index = offsetIndex else { return self }
        return Array(self[index ..< endIndex] + self[startIndex ..< index])
    }
    /**
     Shifts the first elements up to specified distance to the end of the array. If the distance is negative, shifts the last elements up to the specified absolute distance to the beginning of the array.

     If the absolute distance exceeds the number of elements in the array, the elements are not shifted.
     */
    mutating func shiftInPlace(withDistance distance: Int = 1) {
        self = shift(withDistance: distance)
    }
    
    func shuffled() -> [Element] {
        var list = self
        for i in 0..<(list.count - 1) {
            // I need a seeded rand() to make it deterministic
            let upperBound = UInt32(list.count - i)
            let j = Int(UInt32(arc4random()) % upperBound) + i
            //let j = Int(arc4random_uniform(upperBound)) + i
            guard i != j else { continue }
            list.swapAt(i, j)
        }
        return list
    }
}

extension String {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    func substring(from: Int) -> String {
        if from >= self.count {
            return ""
        }
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    func substring(from: Int, to: Int) -> String {
        let a = index(from: from)
        let b = index(from: to)
        return String(self[a..<b])
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

func measure(fn: @escaping ()->Void) -> CFAbsoluteTime {
    let startTime = CFAbsoluteTimeGetCurrent()
    fn()
    let endTime = CFAbsoluteTimeGetCurrent()
    return endTime - startTime
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
