//
//  AppDelegate.swift
//  Battery
//
//  Created by Yiheng Quan on 15/7/19.
//  Copyright © 2019 Yiheng Quan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    private var timer: Timer?
    // From https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos
    // Define a menu
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private let battery = Battery()
    private let menu = NSMenu()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menu.delegate = self
        setupMenu()
        
        updateMenu(text: battery.getTimeRemaining())
        
        // Update time remains everything 5 second
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateMenu(text: self.battery.getTimeRemaining())
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        timer?.invalidate()
        timer = nil
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        // Remove everything and add it again
        menu.removeAllItems()
        setupMenu()
    }
    
    func setupMenu() {
        menu.addItem(NSMenuItem(title: Constant.Version, action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Source code on GitHub", action: #selector(showGitHub), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "About BatteryBar", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // Add more items depeding on output
        // var hasInfo = true
        var info = battery.getDetailedBatteryInfo()
        if info == "" {
            // Provide a default value
            info = "No information available"
            // hasInfo = false
        }
        
        // Add menu items based on output
        let output = info.split(separator: "\n")
        for s in output {
            menu.addItem(NSMenuItem(title: String(s), action: nil, keyEquivalent: ""))
        }
        
        // Display everything
//        if true {
//            menu.addItem(NSMenuItem(title: "Show more info", action: #selector(showAllInfo), keyEquivalent: ""))
//        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit BatteryBar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    /// Open my github repo
    @objc private func showGitHub() {
        let url = URL(string: "https://github.com/HenryQuan/BatteryBar")!
        let ws = NSWorkspace()
        ws.open(url)
    }
    
    /// Show about alert
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = Constant.AboutMessage
        alert.runModal()
    }
    
    /// Show everything inside an alert
    @objc private func showAllInfo() {
        let alert = NSAlert()
        alert.messageText = battery.allInfo
        alert.runModal()
    }
    
    /// Update menu bar time display
    private func updateMenu(text: String) {
        // update everything here
        menu.removeAllItems()
        setupMenu()
        
        if let button = statusItem.button {
            button.title = text
        }
    }
}
