//
//  IORegString.swift
//  BatteryBar
//
//  Created by Yiheng Quan on 24/7/19.
//  Copyright © 2019 Yiheng Quan. All rights reserved.
//

import Cocoa

struct IORegString {

    let description: String
    let value: String

    init(output: String) {
        // Parse string
        if output != "" {
            let temp = output.split(separator: "=")
            description = Self.removeWhitespace(input: temp[0])
            value = Self.removeWhitespace(input: temp[1])
        } else {
            assertionFailure("Output is invalid")
            description = ""
            value = ""
        }
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

    /// Remove white spaces from Substring
    private static func removeWhitespace(input: Substring) -> String {
        var i = String(input)
        i = i.replacingOccurrences(of: " ", with: "")
        i = i.replacingOccurrences(of: "\"", with: "")
        return i
    }
}
