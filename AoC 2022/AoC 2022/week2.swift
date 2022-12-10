//
//  week2.swift
//  AoC 2022
//
//  Created by En David on 10/12/2022.
//

import Foundation

func day8(input: [String], output: String?) {
    let image = SimpleImage(lines: input)
    // part 1
    let visibility = computeTreeVisibility(from: image)
    //print("\(image)\n\n\(visibility)")
    let countVisible = visibility.data.reduce(0, +)
    print("There are \(countVisible) trees.")
    // part 2
    let scenicScores = computeScenicScore(from: image)
    let maxScore = scenicScores.data.reduce(0, Swift.max)
    print("The highest scenic score is \(maxScore)")
    // visualize the input and output (optional)
    guard let output = output else {
        return
    }
    let rooted = scenicScores.data.map { Int(sqrt(Double($0))) }
    let maxRooted = rooted.reduce(0, Swift.max)
    let score2 = SimpleImage(width: image.width, height: image.height, data: rooted)
    if let img1 = image.toCGImage(palette: Color.brownToGreenPalette), let img2 = score2.toCGImage(palette: Color.grayScale(maxValue: maxRooted)) {
        let url1 = URL(fileURLWithPath: "\(output)-input.png")
        let url2 = URL(fileURLWithPath: "\(output)-scenic-scores.png")
        CGImageWriteToFile(img1, filename: url1)
        CGImageWriteToFile(img2, filename: url2)
    }
}
