//
//  Utils.swift
//  Battery
//
//  Created by Yiheng Quan on 24/7/19.
//  Copyright © 2019 Yiheng Quan. All rights reserved.
//

import Cocoa

/// All utility fucntions
class Utils {
    /// Regex
    /// from https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    static func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Run command
    /// from https://stackoverflow.com/questions/29514738/get-terminal-output-after-a-command-swift
    static func runCommand(cmd: String, args: String...) ->
        (output: [String], error: [String], exitCode: Int32)
    {
        var output: [String] = []
        var error: [String] = []
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        // Get output data
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        // Get error data
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
}
