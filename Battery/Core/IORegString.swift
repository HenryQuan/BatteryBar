//
//  IORegString.swift
//  BatteryBar
//
//  Created by Yiheng Quan on 24/7/19.
//  Copyright © 2019 Yiheng Quan. All rights reserved.
//

import Cocoa

class IORegString {
    
    var description = ""
    var value = ""
    
    init(output: String) {
        // Parse string
        if output != "" {
            let temp = output.split(separator: "=")
            self.description = self.removeWhitespace(input: temp[0])
            self.value = self.removeWhitespace(input: temp[1])
        }
    }
    
    /// Remove white spaces from Substring
    private func removeWhitespace(input: Substring) -> String {
        var i = String(input)
        i = i.replacingOccurrences(of: " ", with: "")
        i = i.replacingOccurrences(of: "\"", with: "")
        return i
    }
    
    /// Convert string to corresponding values
    func convertValue() -> Any {
        if value == "Yes" {
            return true
        } else if value == "No" {
            return false
        } else {
            return Int(value)!
        }
    }
    
}
