//
//  ContentView.swift
//  Algo de Example App
//
//  Created by David Gavilan Ruiz on 16/02/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var outputText = "Hello, world!"
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(outputText)
            HStack {
                Button("Test 1", role: nil) {
                    logDebug("Test 1")
                    let out = concurrentDQ(["red", "green", "blue"], op: colorToEmoji)
                    outputText = out.joined(separator: ", ")
                }
                Button("Test 2", role: nil) {
                    logDebug("Test 2")
                    asyncOpDQ(["cyan", "magenta", "yellow", "black"], op: colorToEmoji) { out in
                        outputText = out.joined(separator: ", ")
                    }
                }
                Button("Test 3", role: nil) {
                    logDebug("Test 3")
                    Task {
                        let out = await asyncOp(["red", "yellow", "green", "cyan", "blue", "magenta"], op: colorToEmoji)
                        outputText = out.joined(separator: ", ")
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
