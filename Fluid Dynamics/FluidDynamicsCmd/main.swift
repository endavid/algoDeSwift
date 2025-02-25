//
//  main.swift
//  FluidDynamicsCmd
//
//  Created by David Gavilan Ruiz on 25/02/2025.
//

import Foundation

func printHelpImageSequence(_ f: String, startFrame: Int? = nil) {
    let fileURL = URL(fileURLWithPath: f)
    let name = fileURL.lastPathComponent
    let parent = fileURL.deletingLastPathComponent()
    print("Images saved in \(parent)")
    print("  To resize them (e.g.):\n\tmogrify -resize 10% \(name)*.png")
    print("  \tmogrify -filter point -resize 400% \(name)*.png")
    print("  To create a video from the frames:")
    let s = startFrame != nil ? "-start_number \(startFrame!)" : ""
    print("    \tffmpeg -r 24 -f image2 -s 100x100 \(s) -i \(name)%06d.png -vcodec libx264 -crf 25 -pix_fmt yuv420p output.mp4")
    print("  To create an animated GIF from the frames:")
    print("    \tconvert -delay 1x24 -loop 0 \(name)*.png \(name)anim.gif")
    print("  To reduce the frame rate:")
    print("    \tffmpeg -r 120 .... output.mp4")
    print("    \tffmpeg -i output.mp4 -filter:v fps=30 output-30fps.mp4")
}

func fluidTests(output: String) {
    let boxedFluid = BoxedFluid(n: 256)
    boxedFluid.addBox(1.0, from: (10,10), to: (60,60))
    boxedFluid.addBox(1.0, from: (100,100), to: (150,150))
    boxedFluid.addBox(1.0, from: (200,200), to: (250,250))
    let boxedVelocityField = BoxedVelocityField(n: 256)
    boxedVelocityField.addOmni(magnitude: 0.1, center: (80, 80), radius: 40)
    boxedVelocityField.addOmni(magnitude: -0.1, center: (170, 170), radius: 40)
    if let cgImage = toCGImage(boxedVelocityField.field, valueScale: 8.0) {
        saveNumberedPng(image: cgImage, i: 0, withPrefix: "\(output)v_")
    }
    for i in 0..<20 {
        if let cgImage = toCGImage(boxedFluid.image) {
            saveNumberedPng(image: cgImage, i: i, withPrefix: output)
        }
        boxedFluid.diffuse()
        boxedFluid.advection(velocity: boxedVelocityField)
    }
}

func main() {
    do {
        let output = try parseCLI()
        fluidTests(output: output)
        printHelpImageSequence(output)
    } catch {
        print(error.localizedDescription)
    }
}

main()
