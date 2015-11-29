//
//  StatusBarItemManager.swift
//  Upshot
//
//  Created by Quentin Dommerc on 18/07/15.
//  Copyright © 2015 Quentin Dommerc. All rights reserved.
//

import Foundation
import Cocoa

class StatusBarItemManager : NSObject{
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var settingsMenuItem : NSMenuItem = NSMenuItem()
    var terminateMenuItem : NSMenuItem = NSMenuItem()
    
    var standbyImage = NSImage(named: "status-item-standby")
    var successImage = NSImage(named: "status-item-success")
    var failureImage = NSImage(named: "status-item-error")
    var sendingImage = NSImage(named: "status-item-sending")
    
    override init() {
        super.init()
        
        statusBarItem = statusBar.statusItemWithLength(NSVariableStatusItemLength)
        statusBarItem.menu = menu
        statusBarItem.image = standbyImage
        
        settingsMenuItem.title = "Settings"
        settingsMenuItem.action = Selector("openSettings:")
        settingsMenuItem.keyEquivalent = ""
        settingsMenuItem.target = self
        menu.addItem(settingsMenuItem)
        
        menu.addItem(NSMenuItem.separatorItem())
        
        terminateMenuItem.title = "Quit"
        terminateMenuItem.action = Selector("terminate:")
        terminateMenuItem.keyEquivalent = ""
        menu.addItem(terminateMenuItem)
    }
    
    func reset(timer : NSTimer) {
        statusBarItem.image = standbyImage
    }
    
    func sending(time : NSTimeInterval = 2) -> Void {
        statusBarItem.image = sendingImage
    }
    
    func failure(time : NSTimeInterval = 2) -> Void {
        statusBarItem.image = failureImage
        NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("reset:"), userInfo: nil, repeats: false)
    }
    
    func success(time : NSTimeInterval = 2) -> Void {
        statusBarItem.image = successImage
        NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("reset:"), userInfo: nil, repeats: false)
    }
    
    func openSettings(object: AnyObject) {
        
        NSApp.appDelegate.showSettingsWindow()
    }
}

