//
//  Filesystem.swift
//  AoC 2022
//
//  Created by En David on 10/12/2022.
//

import Foundation

class Filesystem {
    class Dir {
        var name: String
        var files: [(name: String, size: Int)] = []
        var dirs: [String: Dir] = [:]
        var parent: Dir?
        
        var fullpath: String {
            get {
                var n = name
                var p = parent
                while p != nil {
                    n = p!.name + "/" + n
                    p = p!.parent
                }
                return n
            }
        }
        
        var size: Int {
            get {
                let filesize = files.reduce(0, {$0 + $1.size})
                let dirsize = dirs.reduce(0, {$0 + $1.value.size})
                return filesize + dirsize
            }
        }
        
        init(name: String, parent: Dir? = nil) {
            self.name = name
            self.parent = parent
        }
    }
    
    var root = Dir(name: "")
    var dirPointers: [String: Dir] = [:]
    
    func dump(dir: Dir, prefix: String = "") {
        print(prefix + dir.fullpath)
        for file in dir.files {
            print("\(prefix)\(file)")
        }
        for d in dir.dirs {
            dump(dir: d.value, prefix: prefix + "\t")
        }
    }
    
    init(log: [String]) {
        var cwd = root
        dirPointers[""] = root
        var ls = false
        for line in log {
            let args = line.split(separator: " ").map { String($0) }
            if args[0] == "$" {
                ls = false
                if args[1] == "cd" {
                    switch(args[2]) {
                    case "/":
                        cwd = dirPointers[""]!
                    case "..":
                        if let p = cwd.parent {
                            cwd = p
                        }
                    default:
                        cwd = cwd.dirs[args[2]]!
                    }
                } else if args[1] == "ls" {
                    ls = true
                }
            } else if ls {
                if args[0] == "dir" {
                    let d = Dir(name: args[1], parent: cwd)
                    cwd.dirs[d.name] = d
                    dirPointers[d.fullpath] = d
                } else {
                    let size = Int(args[0])!
                    let filename = args[1]
                    cwd.files.append((filename, size))
                }
            }
        }
    }
}
