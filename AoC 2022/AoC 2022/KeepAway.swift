//
//  KeepAway.swift
//  AoC 2022
//
//  Created by En David on 02/02/2023.
//

import Foundation
import RegexBuilder

class KeepAway {
    class Monkey: CustomStringConvertible {
        enum Op: String {
            case add = "+"
            case mult = "*"
            case sq = "* old"
        }
        let index: Int
        let op: Op
        let rhs: Int // right-hand side of the op
        let base: Int
        let indexTrue: Int
        let indexFalse: Int
        var items: [Int]
        
        var description: String {
            get {
                return "monkey \(index): op(\(op.rawValue), \(rhs)), base \(base), indexTrue \(indexTrue), indexFalse \(indexFalse), items \(items)"
            }
        }
        
        func playTurn(worryControl: ((Int) -> (Int))) -> [Int: [Int]] {
            let updated = items.map { worry in
                var w = worry
                switch(op) {
                case .add:
                    w += rhs
                case .mult:
                    w *= rhs
                case .sq:
                    w *= w
                }
                return worryControl(w)
            }
            var out: [Int: [Int]] = [
                indexTrue: [],
                indexFalse: []
            ]
            for worry in updated {
                if worry % base == 0 {
                    out[indexTrue]?.append(worry)
                } else {
                    out[indexFalse]?.append(worry)
                }
            }
            items.removeAll()
            return out
        }
        
        init?(_ s: String) {
            let getInt = TryCapture {
                OneOrMore(.digit)
            } transform: { Int($0) }
            let regex = Regex {
                "Monkey "
                getInt
                ":\t  Starting items: "
                Capture(/(?:\d+(?:,\s)?)*/)
                "\t  Operation: new = old "
                TryCapture {
                    ChoiceOf {
                        "+"
                        "*"
                        "* old"
                    }
                } transform: { Op(rawValue: String($0)) }
                /(?:\s(\d+))?/
                "\t  Test: divisible by "
                getInt
                "\t    If true: throw to monkey "
                getInt
                "\t    If false: throw to monkey "
                getInt
                /\t?/
            }
            if let m = try? regex.wholeMatch(in: s)?.output {
                index = m.1
                items = m.2.split(separator: ", ").compactMap { Int($0) }
                op = m.3
                rhs = Int(m.4 ?? "0")!
                base = m.5
                indexTrue = m.6
                indexFalse = m.7
            } else {
                return nil
            }
        }
    }
    
    var monkeys: [Monkey]
    var inspectionCount: [Int]
    var worryControl: (Int) -> (Int)
    
    var monkeyBusinessLevel: Int {
        get {
            return inspectionCount.sorted(by: >)[0..<2].reduce(1, *)
        }
    }
    
    func playRound() {
        for m in monkeys {
            inspectionCount[m.index] += m.items.count
            let itemSplit = m.playTurn(worryControl: worryControl)
            for (index, worries) in itemSplit {
                monkeys[index].items.append(contentsOf: worries)
            }
        }
    }
    
    func dumpItems() {
        for m in monkeys {
            print("🐵[\(m.index)] = \(m.items)")
        }
    }
    
    func play(rounds: Int, debug: Bool) {
        print("There are \(monkeys.count) monkeys")
        if (debug) {
            print(monkeys)
        }
        for i in 0..<rounds {
            playRound()
            if (debug) {
                print("Round \(i+1)")
                dumpItems()
            }
        }
        print("Inspection count: \(inspectionCount)")
        print("Monkey business level = \(monkeyBusinessLevel)")
    }
    
    init(notes: [String], worryControl: ((Int) -> (Int))? = nil) {
        let descriptions = notes.chunked(into: 7).map { $0.joined(separator: "\t") }
        monkeys = descriptions.compactMap { Monkey($0) }
        inspectionCount = [Int].init(repeating: 0, count: monkeys.count)
        if let wc = worryControl {
            self.worryControl = wc
        } else {
            // find min common multiple
            let m = monkeys.reduce(1, { $0 * $1.base })
            self.worryControl = { $0 % m }
        }
    }
}
