//
//  images.swift
//  AoC 2022
//
//  Created by En David on 28/11/2022.
//

import Foundation
import CoreGraphics
import ImageIO

typealias Coord2D = (x: Int, y: Int)

enum ImageError: LocalizedError {
    case cantCreateCGImage
    
    var errorDescription: String? {
        switch self {
        case .cantCreateCGImage:
            return "Can not create CGImage"
        }
    }
}

struct SimpleImage: CustomStringConvertible {
    let width: Int
    let height: Int
    
    var data: [Int]
    
    var description: String {
        get {
            let chunks = data.chunked(into: width)
            let rows = chunks.map { $0.reduce("", {$0 + String($1)}) }
            return rows.joined(separator: "\n")
        }
    }
    
    func toHashes(empty: String = " ") -> String {
        let chunks = data.chunked(into: width)
        let m: [Int: String] = [0: empty, 1: "#"]
        let rows = chunks.map { $0.reduce("", {$0 + m[$1, default: "@"]}) }
        return rows.joined(separator: "\n")
    }
    
    func isValid(_ p: Coord2D) -> Bool {
        return p.x >= 0 && p.x < width && p.y >= 0 && p.y < height
    }
    
    func index(_ p: Coord2D) -> Int {
        return p.y * width + p.x
    }
    func index(_ p: Vec2) -> Int {
        return p.y * width + p.x
    }
    
    func getValue(_ p: Coord2D) -> Int {
        return data[index(p)]
    }
    
    mutating func setValue(_ v: Int, at c: Coord2D) {
        data[index(c)] = v
    }
    mutating func setValue(_ v: Int, at c: Vec2) {
        data[index(c)] = v
    }
    
    func getRow(_ y: Int) -> [Int] {
        let a = y * width
        let b = (y+1) * width
        return Array(data[a..<b])
    }
    
    func getColumn(_ x: Int) -> [Int] {
        return (0..<height).map { getValue((x,$0)) }
    }
    
    func get4Neighbors(_ p: Coord2D) -> [Coord2D] {
        return [
            // NSEW
            (p.x - 1, p.y),
            (p.x, p.y - 1),
            (p.x + 1, p.y),
            (p.x, p.y + 1)
        ].filter { isValid($0) }
    }
    
    func getNeighborValuesToEdges(_ c: Coord2D) -> [ArraySlice<Int>] {
        let row = getRow(c.y)
        let column = getColumn(c.x)
        var left = row[0..<c.x]
        left.reverse()
        var up = column[0..<c.y]
        up.reverse()
        return [
            left,
            row[c.x+1..<width],
            up,
            column[c.y+1..<height]
        ]
    }
    
    init(width: Int, height: Int, data: [Int]) {
        self.width = width
        self.height = height
        self.data = data
    }
    
    init(width: Int, height: Int, value: Int = 0) {
        self.width = width
        self.height = height
        self.data = [Int].init(repeating: value, count: width * height)
    }
    
    init(lines: [String]) {
        height = lines.count
        width = lines.first?.count ?? 0
        data = lines.flatMap { $0.compactMap { Int(String($0)) } }
    }
    
    // MARK: Image formats
    func toPgm() -> String {
        let s = "P2\n# image.pgm\n\(width) \(height)\n9\n"
        let chunks = data.chunked(into: width)
        let rows = chunks.map { $0.reduce("", {$0 + " " + String($1)}) }
        return s + rows.joined(separator: "\n")
    }
    
    func toCGImage(palette: Palette) -> CGImage? {
        let bytesPerPixel = 4 // RGBA
        let pixelCount = width * height
        let bitsPerComponent = 8
        var imageBytes = [UInt8].init(repeating: 0, count: pixelCount * bytesPerPixel)
        for i in 0..<data.count {
            let c = data[i]
            let color = palette[min(c, palette.count - 1)]
            imageBytes[4 * i] = UInt8(color.r)
            imageBytes[4 * i + 1] = UInt8(color.g)
            imageBytes[4 * i + 2] = UInt8(color.b)
            imageBytes[4 * i + 3] = 255
        }
        guard let provider = CGDataProvider(data: NSData(bytes: &imageBytes, length: pixelCount * bytesPerPixel * MemoryLayout<UInt8>.size)) else {
            return nil
        }
        let bitmapInfo: CGBitmapInfo = [.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)]
        return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bytesPerPixel * bitsPerComponent, bytesPerRow: width * bytesPerPixel, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
    
    func savePng(filename: String, palette: Palette) throws {
        guard let cgImage = toCGImage(palette: palette) else {
            throw ImageError.cantCreateCGImage
        }
        let file = URL(filePath: filename)
        CGImageWriteToFile(cgImage, filename: file)
    }
    
    func saveNumberedPng(i: Int, withPrefix pre: String, palette: Palette) throws {
        let number = String(format: "%04d", i)
        try savePng(filename: "\(pre)\(number).png", palette: palette)
    }
}

/** Saves image to disk
*  @see http://stackoverflow.com/questions/1320988/saving-cgimageref-to-a-png-file
*/
func CGImageWriteToFile(_ image: CGImage, filename: URL) {
    let url = filename as CFURL
    guard let destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil) else {
        NSLog("Failed to create destination: \(url)")
        return
    }
    CGImageDestinationAddImage(destination, image, nil)
    if !CGImageDestinationFinalize(destination) {
        NSLog("Failed to write image to \(filename)")
    }
}

