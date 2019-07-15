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

    // Define a menu
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Show "Hello World"
        if let button = statusItem.button {
            button.title = "Hello World"
        }
        
        print(updateTimeRemain())
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func updateTimeRemain() -> String {
        var remain = "unkown";
        // pmset -g batt
        let output = runCommand(cmd: "/usr/bin/pmset", args: "-g", "batt").output
        let time = output[1].split(separator: ";").last
        if time != nil {
            remain = String(time!)
        }
        return remain
    }
    
    /// From https://stackoverflow.com/questions/29514738/get-terminal-output-after-a-command-swift
    /// Run command
    func runCommand(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32) {
        
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
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
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

