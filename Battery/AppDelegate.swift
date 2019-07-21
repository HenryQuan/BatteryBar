//
//  AppDelegate.swift
//  Battery
//
//  Created by Yiheng Quan on 15/7/19.
//  Copyright © 2019 Yiheng Quan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // From https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos
    // Define a menu
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    var timer: Timer?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.setupMenu()
        
        self.updateMenu(text: self.updateTimeRemain())
        // Update time remains everything 10 second
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (_) in
            self.updateMenu(text: self.updateTimeRemain())
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        self.timer = nil
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: Constant.Version, action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    /// Show about alert
    @objc func showAbout() {
        let alert = NSAlert.init()
        alert.messageText = "BatteryBar shows an estimation of how much time remaining for your MacBook"
        
        alert.runModal()
    }
    
    /// Update menu bar time display
    func updateMenu(text: String) {
        if let button = self.statusItem.button {
            button.title = text
        }
    }

    /// Get time remain for this machine
    /// Returns a string like 2:12 remaning
    func updateTimeRemain() -> String {
        var remain = Constant.Estimate;
        // pmset -g batt
        let output = runCommand(cmd: "/usr/bin/pmset", args: "-g", "batt").output
        
        // Find string with format 1:23
        let matches = self.matches(for: "[0-9]+:[0-9]+", in: output[1])
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
    
    /// From https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    /// Regex
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    /// From https://stackoverflow.com/questions/29514738/get-terminal-output-after-a-command-swift
    /// Run command
    func runCommand(cmd: String, args: String...) -> (output: [String], error: [String], exitCode: Int32) {
        var output : [String] = []
        var error : [String] = []
        
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

