//
//  SimpleImage.swift
//  FluidDynamicsCmd
//
//  Created by David Gavilan Ruiz on 25/02/2025.
//

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

typealias Coord2D = (x: Int, y: Int)

struct SimpleImage<T: Numeric> {
    let width: Int
    let height: Int
    var data: [T]
    
    func index(_ x: Int, _ y: Int) -> Int {
        return y * width + x
    }
    func isValid(_ p: Coord2D) -> Bool {
        return p.x >= 0 && p.x < width && p.y >= 0 && p.y < height
    }
    func get(_ x: Int, _ y: Int) -> T {
        return data[index(x,y)]
    }
    func get(_ p: Coord2D) -> T {
        return data[index(p.x, p.y)]
    }
    func get4Neighbors(_ p: Coord2D) -> [Coord2D] {
        return [
            // NSEW
            (p.x - 1, p.y),
            (p.x, p.y - 1),
            (p.x + 1, p.y),
            (p.x, p.y + 1)].filter { isValid($0) }
    }
    func get4NeighborValues(_ p: Coord2D) -> [T] {
        return get4Neighbors(p).map(self.get)
    }
    mutating func setValue(_ v: T, at coord: Coord2D) {
        data[index(coord.x, coord.y)] = v
    }
    mutating func addValue(_ v: T, at coord: Coord2D) {
        data[index(coord.x, coord.y)] += v
    }
    mutating func drawBox(_ v: T, from a: Coord2D, to b: Coord2D) {
        let rangex = a.x > b.x ? b.x...a.x : a.x...b.x
        let rangey = a.y > b.y ? b.y...a.y : a.y...b.y
        for y in rangey {
            for x in rangex {
                addValue(v, at: (x,y))
            }
        }
    }
    init(width: Int, height: Int, value: T) {
        self.width = width
        self.height = height
        self.data = [T].init(repeating: value, count: width * height)
    }
}


func toCGImage(_ img: SimpleImage<Double>, valueScale: Double = 255.0) -> CGImage? {
    let pixelCount = img.width * img.height
    let bitsPerComponent = 8
    var imageBytes = [UInt8].init(repeating: 0, count: pixelCount)
    for i in 0..<img.data.count {
        let c = img.data[i]
        imageBytes[i] = UInt8(min(255.0, max(c * valueScale, 0)))
    }
    guard let provider = CGDataProvider(data: NSData(bytes: &imageBytes, length: pixelCount * MemoryLayout<UInt8>.size)) else {
        return nil
    }
    let bitmapInfo:CGBitmapInfo = [.byteOrderDefault]
    return CGImage(
        width: img.width,
        height: img.height,
        bitsPerComponent: bitsPerComponent,
        bitsPerPixel: bitsPerComponent,
        bytesPerRow: img.width,
        space: CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)!,
        bitmapInfo: bitmapInfo,
        provider: provider,
        decode: nil,
        shouldInterpolate: false,
        intent: .defaultIntent
    )
}

/** Saves image to disk
*  @see http://stackoverflow.com/questions/1320988/saving-cgimageref-to-a-png-file
*/
func CGImageWriteToFile(_ image: CGImage, filename: URL) {
    let url = filename as CFURL
    guard let destination = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil) else {
        NSLog("Failed to create destination: \(url)")
        return
    }
    CGImageDestinationAddImage(destination, image, nil)
    if !CGImageDestinationFinalize(destination) {
        NSLog("Failed to write image to \(filename)")
    }
}

func saveNumberedPng(image: CGImage, i: Int, withPrefix pre: String) {
    let number = String(format: "%06d", i)
    let fileURL = URL(fileURLWithPath: "\(pre)\(number).png")
    CGImageWriteToFile(image, filename: fileURL)
}
