//
//  crypto.swift
//  AoC 2015
//
//  Created by En David on 21/11/2022.
//

import Foundation
import CommonCrypto

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { bytes -> [UInt8] in
            var h = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &h)
            return h
        }
        // Hexa string: 20 -> "14", 1 -> "01"
        // ["14", "01"] --> "1401"
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

func findHashWithMD5That(startsWith trailing: String, key: String, start: Int = 0) -> (String, String, Int) {
    var hash = ""
    var md5 = "123456789"
    var i = start
    while md5.substring(to: trailing.count) != trailing {
        hash = "\(key)\(i)"
        md5 = hash.md5
        i += 1
    }
    return (hash, md5, i)
}
