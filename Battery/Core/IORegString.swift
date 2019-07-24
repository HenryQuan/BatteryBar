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
    
    // A list of useful descriptions
    private let useful = ["", "", "", "", "", "", "", ""]
    
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
        return String(input).replacingOccurrences(of: " ", with: "")
    }
}
