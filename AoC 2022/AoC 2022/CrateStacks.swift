//
//  CrateStacks.swift
//  AoC 2022
//
//  Created by En David on 09/12/2022.
//

import Foundation
import RegexBuilder

class CrateStacks {
    typealias Instruction = (count: Int, from: Int, to: Int)
    var stacks: [[Character]] = []
    var instructions: [Instruction] = []
    
    var top: String {
        get {
            return stacks.reduce("", { s, stack in
                s + String(stack.first!)
            })
        }
    }
    
    func apply(instruction i: Instruction) {
        for _ in 0..<i.count {
            let c = stacks[i.from].removeFirst()
            stacks[i.to].insert(c, at: 0)
        }
    }
    
    func applyNew(instruction i: Instruction) {
        let crates = stacks[i.from][0..<i.count]
        stacks[i.from].removeFirst(i.count)
        stacks[i.to].insert(contentsOf: crates, at: 0)
    }
    func applyAll() {
        for i in instructions {
            apply(instruction: i)
        }
    }
    
    func applyAllNew() {
        for i in instructions {
            applyNew(instruction: i)
        }
    }
    
    static func parseInstruction(_ s: String) -> Instruction? {
        let getInt = TryCapture {
            OneOrMore(.digit)
        } transform: { Int($0) }
        let regex = Regex {
            "move "
            getInt
            " from "
            getInt
            " to "
            getInt
        }
        if let m = try? regex.wholeMatch(in: s)?.output {
            return (m.1, m.2 - 1, m.3 - 1)
        }
        return nil
    }
    
    init(input: [String]) {
        var k = 0
        // parse stacks
        while k < input.count {
            let line = input[k]
            if line.isEmpty {
                break
            }
            // e.g. "[Z] [M] [P]"
            for i in stride(from: 1, to: line.count, by: 4) {
                let c = line[line.index(from: i)]
                let stackIndex = i / 4
                if stackIndex >= stacks.count {
                    stacks.append([])
                }
                if let _ = Int(String(c)) {
                    // ignore line with digits
                    break
                }
                if c != Character(" ") {
                    stacks[stackIndex].append(c)
                }
            }
            k += 1
        }
        // parse instructions
        instructions = input[(k+1)..<input.count].compactMap(CrateStacks.parseInstruction)
    }
}
