//
//  Battery.swift
//  BatteryBar
//
//  Created by Yiheng Quan on 24/7/19.
//  Copyright © 2019 Yiheng Quan. All rights reserved.
//

import Cocoa

class Battery {

    var allInfo = ""
    
    /// Get time remaining for this machine
    /// Returns a string like 2:12 remaning
    func getTimeRemaining() -> String {
        var remain = Constant.Estimate
        var batteryPercentage = ""
        // pmset -g batt
        let output = Utils.runCommand(cmd: "/usr/bin/pmset", args: "-g", "batt").output
        
        // Find string with format 1:23
        if output.count > 1 {
            let matches = Utils.matches(for: "[0-9]+:[0-9]+", in: output[1])
            if matches.count > 0 {
                remain = matches[0]
            }
            
            let percentMatches = Utils.matches(for: "[0-9]+%", in: output[1])
            if percentMatches.count > 0 {
                batteryPercentage = percentMatches[0]
            }
        }

        // Add different emoji to distinguish different mode
        if output.joined().contains("discharg") {
            remain += "🔋"
        } else {
            remain += "⚡️"
        }
        
        // Add the percentage
        remain += batteryPercentage
        
        return remain
    }
    
    /// Get more detailed information like design/max capacity, cycle count and an estimated battery health.
    /// All data are from ioreg command
    func getDetailedBatteryInfo() -> String {
        print("getDetailedBatteryInfo...")
        
        // Get output from ioreg -brc AppleSmartBattery
        let output = Utils.runCommand(cmd: "/usr/sbin/ioreg", args: "-brc", "AppleSmartBattery")
            .output.dropLast().dropFirst().joined(separator: "\n")
        self.allInfo = self.formatOutput(output: output)
        
        let matches = Utils.matches(for: "\"(.*?)\" = (.*)", in: output)
        // To format nicelt
        var max = 0
        var cycle = 0
        var design = 0
        
        for m in matches {
            let curr = IORegString(output: m)
            switch curr.description {
            case "MaxCapacity":
                let capacity = curr.convertValue() as! Int
                if (capacity > 1000) {
                    #warning("This is 100 on M1")
                    max = capacity
                }
            case "AppleRawMaxCapacity":
                max = curr.convertValue() as! Int
            case "CycleCount":
                cycle = curr.convertValue() as! Int
            case "DesignCapacity":
                design = curr.convertValue() as! Int
            default:
                break
            }
        }
        
        var finalResult = ""
        // There must be a design capcacity, if not we failed to get any data
        if design > 0 {
            finalResult += "Cycle count: \(cycle)/1000\n"
            let percentage = max * 100 / design
            finalResult += "Battery health: \(max)/\(design) (\(percentage)%)\n"
        } else {
            finalResult += "No battery information\n"
        }
        finalResult += "Uptime: \(self.getUpTime())\n"
        return finalResult
    }
    
    /// Get uptime from 'uptime' command
    private func getUpTime() -> String {
        let output = Utils.runCommand(cmd: "/usr/bin/uptime", args: "").output.joined()
        let matches = output.groups(for: "up (.*?),")
        
        var uptime = "??"
        // check there are matches and make sure capture is also correct
        if matches.count > 0, matches[0].count > 1 {
            uptime = matches[0][1]
        }
        return uptime
    }
    
    /// Remove = and "
    private func formatOutput(output: String) -> String {
        var t = output.replacingOccurrences(of: " =", with: ":")
        t = t.replacingOccurrences(of: "\"", with: "")
        return t
    }
}
