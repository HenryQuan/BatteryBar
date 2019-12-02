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
    func updateTimeRemaining() -> String {
        var remain = Constant.Estimate;
        // pmset -g batt
        let output = Utils.runCommand(cmd: "/usr/bin/pmset", args: "-g", "batt").output
        
        // Find string with format 1:23
        let matches = Utils.matches(for: "[0-9]+:[0-9]+", in: output[1])
        if matches.count > 0 {
            remain = matches[0]
        }
        
        // Add different emoji to distinguish different mode
        if output.joined().contains("discharg") {
            remain += "🔋"
        } else {
            remain += "⚡️"
        }
        
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
            finalResult += "Uptime: \(self.getUpTime())\n"
        }
        return finalResult
    }
    
    /// Get uptime from 'uptime' command
    private func getUpTime() -> String {
        let output = Utils.runCommand(cmd: "/usr/bin/uptime", args: "").output.joined()
        let matches = Utils.matches(for: "up (.*?),", in: output)
        
        var uptime = "??"
        if matches.count > 0 {
            // up 10:1, -> 10:1
            uptime = String(matches[0].split(separator: " ")[1].split(separator: ",")[0])
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
