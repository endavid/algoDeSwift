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

func day12(input: [String], output: String?) {
    let hill = Hill(lines: input)
    // part 1
    hill.climb(from: hill.start)
    print("Climbed from \(hill.start) to \(hill.end) in \(hill.stepsShortest) steps")
    // part 2
    let hill2 = Hill(lines: input)
    hill2.descend(from: hill.end)
    var shortest = Int.max
    for y in 0..<hill2.image.height {
        for x in 0..<hill2.image.width {
            let c = (x, y)
            let h = hill2.image.getValue(c)
            if h != 0 {
                continue
            }
            let steps = hill2.shortest.getValue(c)
            if steps < shortest {
                print("\(c) is shorter: \(steps)")
                shortest = steps
            }
        }
    }
    print("best: \(shortest)")
    guard let output = output else {
        return
    }
    let paletteHill = Color.heatmap(low: Color(hexValue: 0x3B270B), mid: Color(hexValue: 0x67C926), high: .white, maxValue: 25)
    var palette = Color.heatmap(low: .blue, mid: .green, high: .red, maxValue: hill.stepsShortest)
    palette.append(.white)
    if let img = hill.image.toCGImage(palette: paletteHill), let img2 = hill.shortest.toCGImage(palette: palette), let img3 = hill2.shortest.toCGImage(palette: palette) {
        let url = URL(fileURLWithPath: "\(output)hill.png")
        CGImageWriteToFile(img, filename: url)
        let url2 = URL(fileURLWithPath: "\(output)ascend.png")
        CGImageWriteToFile(img2, filename: url2)
        let url3 = URL(fileURLWithPath: "\(output)descend.png")
        CGImageWriteToFile(img3, filename: url3)
    }
}

func day13(input: [String]) {
    // part 1
    let pairs = input.chunked(into: 3).map { ($0[0], $0[1]) }
    let rightOrderCount = (0..<pairs.count).reduce(0) { sum, i in
        let v = compareLists(pairs[i].0, pairs[i].1)
        return sum + (v < 0 ? i + 1 : 0)
    }
    print("Right order count = \(rightOrderCount)")
    // part 2
    var all = input.filter { !$0.isEmpty }
    all.sort { compareLists($0, $1) < 0 }
    print(all)
    let i1 = all.binarySearch { compareLists($0, "[[2]]") < 0 }
    let i2 = all.binarySearch { compareLists($0, "[[6]]") < 0 }
    let key = (i1 + 1) * (i2 + 2)
    print("decoder key = \(key)")
}
