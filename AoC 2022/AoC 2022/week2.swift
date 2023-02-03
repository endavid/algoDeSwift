//
//  week2.swift
//  AoC 2022
//
//  Created by En David on 10/12/2022.
//

import Foundation

func printHelpImageSequence(_ f: String) {
    let fileURL = URL(fileURLWithPath: f)
    let name = fileURL.lastPathComponent
    let parent = fileURL.deletingLastPathComponent()
    print("Images saved in \(parent)")
    print("  To resize them (e.g.):\n\tmogrify -resize 10% \(name)*.png")
    print("  \tmogrify -filter point -resize 400% \(name)*.png")
    print("  To create a video from the frames:")
    print("    \tffmpeg -r 24 -f image2 -s 100x100 -i \(name)%04d.png -vcodec libx264 -crf 25 -pix_fmt yuv420p output.mp4")
    print("  To create an animated GIF from the frames:")
    print("    \tconvert -delay 1x24 -loop 0 \(name)*.png \(name)anim.gif")
}


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

func day9(input: [String], output: String?) throws {
    let sim = RopeSim()
    // part 1
    for line in input {
        sim.move(line)
    }
    print("Tail visited \(sim.visited.count) unique positions")
    // part 2
    let sim10 = RopeSim(ropeLength: 10)
    for line in input {
        sim10.move(line)
    }
    print("Tail visited \(sim10.visited.count) unique positions for rope length 10")
    if let o = output {
        let imgSize = sim10.bottomRight - sim10.topLeft + Vec2(1, 1)
        let w = 2*((imgSize.x+1)/2)
        let h = 2*((imgSize.y+1)/2)
        let offset = Vec2.zero - sim10.topLeft
        let maxVisits = sim10.visited.values.reduce(0, Swift.max)
        print("image size: \(imgSize) -> \(w)x\(h); offset: \(offset); maxVisits: \(maxVisits)")
        let sim = RopeSim(ropeLength: 10)
        var frame = 0
        var palette = Color.brownToGreenPalette
        palette.insert(Color(hexValue: 0xff22ff), at: 1)
        for i in 2...10 { // make all green
            palette[i] = Color(hexValue: 0x11ff11)
        }
        palette = palette + Color.redToYellow(maxValue: maxVisits)
        for line in input {
            sim.move(line)
            var img = SimpleImage(width: w, height: h)
            // draw visits
            for (k, v) in sim.visited {
                img.setValue(v + 11, at: k + offset)
            }
            // draw rope
            for i in (0..<sim.rope.count).reversed() {
                img.setValue(10 - i, at: sim.rope[i] + offset)
            }
            try img.saveNumberedPng(i: frame, withPrefix: o, palette: palette)
            frame += 1
        }
        printHelpImageSequence(o)
    }
}

func day10(input: [String]) {
    var cycle = 1
    var X = 1
    var strengths: [Int] = []
    var image = SimpleImage(width: 40, height: 6)
    let incCycle = { () in
        if cycle % 40 == 20 {
            strengths.append(X * cycle)
        }
        let y = (cycle - 1) / image.width
        let x = (cycle - 1) % image.width
        if x >= X-1 && x <= X+1 {
            image.setValue(1, at: (x,y))
        }
        cycle += 1
    }
    for line in input {
        if line == "noop" {
            incCycle()
        } else {
            // addx V
            let args = line.split(separator: " ")
            incCycle()
            incCycle()
            X += Int(args[1])!
        }
    }
    // part 1
    print(strengths)
    let total = strengths.reduce(0, +)
    print("sum of six signal strengths is \(total)")
    // part 2
    print(image.toHashes())
}


func day11(input: [String]) {
    // part 1
    let play1 = KeepAway(notes: input) { $0 / 3 }
    play1.play(rounds: 20, debug: true)
    // part 2
    let play2 = KeepAway(notes: input)
    play2.play(rounds: 10000, debug: false)
}
