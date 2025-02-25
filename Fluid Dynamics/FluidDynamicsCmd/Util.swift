//
//  Util.swift
//  FluidDynamicsCmd
//
//  Created by David Gavilan Ruiz on 25/02/2025.
//

import Foundation

enum CLIError: LocalizedError {
    case noInputFile
    case fileDoesNotExist(name: String)
    
    var errorDescription: String? {
        switch self {
        case .noInputFile:
            return "No input file"
        case .fileDoesNotExist(let f):
            return "\(f) does not exist"
        }
    }
}

func parseCLI() throws -> String {
    if CommandLine.arguments.count == 1 {
        throw CLIError.noInputFile
    }
    return CommandLine.arguments[1]
}
