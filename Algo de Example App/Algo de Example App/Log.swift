//
//  Log.swift
//  Algo de Example App
//
//  Created by David Gavilan Ruiz on 16/02/2024.
//

import Foundation

func logDebug(_ text: String) {
    #if DEBUG
    print(text)
    #endif
}
