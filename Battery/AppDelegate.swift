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
        timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { (_) in
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
        menu.addItem(NSMenuItem(title: "GitHub", action: #selector(showGitHub), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit BatteryBar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    /// Open my github repo
    @objc func showGitHub() {
        let url = URL(string: "https://github.com/HenryQuan/BatteryBar")!
        let ws = NSWorkspace.init()
        ws.open(url)
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

}

