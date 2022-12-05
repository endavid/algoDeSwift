//
//  RockPaperScissors.swift
//  AoC 2022
//
//  Created by En David on 02/12/2022.
//

import Foundation

class RockPaperScissors {
    enum Hand: String {
        case rock = "A"
        case paper = "B"
        case scissors = "C"
    }
    enum Strategy: String {
        case lose = "X"
        case draw = "Y"
        case win = "Z"
    }
    let handScores: [Hand: Int] = [
        .rock: 1,
        .paper: 2,
        .scissors: 3
    ]
    let winningHands: [Hand: Hand] = [
        .rock: .scissors,
        .paper: .rock,
        .scissors: .paper
    ]
    let losingHands: [Hand: Hand] = [
        .scissors: .rock,
        .rock: .paper,
        .paper: .scissors
    ]
    
    func parseHand(_ c: Substring) -> Hand? {
        if let hand = Hand(rawValue: String(c)) {
            return hand
        }
        switch(c) {
        case "X":
            return .rock
        case "Y":
            return .paper
        case "Z":
            return .scissors
        default:
            return nil
        }
    }
    
    func scoreGame(opponent: Hand, you: Hand) -> Int {
        let shapeScore = handScores[you]!
        if opponent == you {
            return 3 + shapeScore
        }
        if winningHands[you] == opponent {
            return 6 + shapeScore
        }
        return shapeScore
    }
    
    func scoreGame(opponent: Hand, you: Strategy) -> Int {
        switch(you) {
        case .lose:
            let yours = winningHands[opponent]!
            return handScores[yours]!
        case .draw:
            return 3 + handScores[opponent]!
        case .win:
            let yours = losingHands[opponent]!
            return 6 + handScores[yours]!
        }
    }
    
    func playStrategy(input: [String]) -> Int {
        let plan = input.compactMap { line in
            let hands = line.split(separator: " ").compactMap(parseHand)
            if hands.count == 2 {
                return (hands[0], hands[1])
            }
            return nil
        }
        let scores = plan.map { round in
            scoreGame(opponent: round.0, you: round.1)
        }
        return scores.reduce(0, +)
    }
    
    func playRightStrategy(input: [String]) -> Int {
        let plan = input.compactMap { line -> (Hand, Strategy)? in
            let hands = line.split(separator: " ").compactMap({String($0)})
            if hands.count != 2 {
                return nil
            }
            if let hand = Hand(rawValue: hands[0]), let strategy = Strategy(rawValue: hands[1]) {
                return (hand, strategy)
            }
            return nil
        }
        let scores = plan.map { round in
            scoreGame(opponent: round.0, you: round.1)
        }
        return scores.reduce(0, +)
    }
}
