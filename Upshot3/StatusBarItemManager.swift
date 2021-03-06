//
//  StatusBarItemManager.swift
//  Upshot
//
//  Created by Cédric Eugeni on 25/06/2019.
//  Copyright © 2019 Cédric Eugeni. All rights reserved.
//

import Foundation
import Cocoa

class StatusBarItemManager : NSObject{
    var statusBar = NSStatusBar.system
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
        
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.menu = menu
        statusBarItem.button?.image = standbyImage
//        statusBarItem.image = standbyImage
        
        statusBarItem.button?.window?.registerForDraggedTypes([.fileURL])
        statusBarItem.button?.window?.delegate = self
        
        settingsMenuItem.title = "Settings"
        settingsMenuItem.action = #selector(StatusBarItemManager.openSettings(_:))
        settingsMenuItem.keyEquivalent = ""
        settingsMenuItem.target = self
        menu.addItem(settingsMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        terminateMenuItem.title = "Quit"
        terminateMenuItem.action = #selector(NSApplication.shared.terminate)
        terminateMenuItem.keyEquivalent = ""
        menu.addItem(terminateMenuItem)
    }
    
    @objc func reset(_ timer : Timer) {
        statusBarItem.image = standbyImage
    }
    
    func sending(_ time : TimeInterval = 2) -> Void {
        statusBarItem.image = sendingImage
    }
    
    func failure(_ time : TimeInterval = 2) -> Void {
        statusBarItem.image = failureImage
        Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(StatusBarItemManager.reset(_:)), userInfo: nil, repeats: false)
    }
    
    func success(_ time : TimeInterval = 2) -> Void {
        statusBarItem.image = successImage
        Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(StatusBarItemManager.reset(_:)), userInfo: nil, repeats: false)
    }
    
    @objc func openSettings(_ object: AnyObject) {
        
        NSApp.appDelegate.showSettingsWindow()
    }
}

extension StatusBarItemManager: NSWindowDelegate {
    
}

extension StatusBarItemManager: NSDraggingDestination {
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        let pasteBoard = sender.draggingPasteboard
        
        if let types = pasteBoard.types, types.contains(.fileURL),
            let files = pasteBoard.propertyList(forType: .fileURL) as? [String] {
            
            for file in files {
                
                var isDir = ObjCBool(false)
                if FileManager.default.fileExists(atPath: file, isDirectory: &isDir) && isDir.boolValue == false {
                    do {
                        let attributes = try FileManager.default.attributesOfItem(atPath: file)
                        
                        if let fileSize = attributes[FileAttributeKey.size] as? UInt {
                            
                            if fileSize < 5 * 1024 * 1024 {
                                
                                let url = URL(fileURLWithPath: file)
                                
                                NSApp.appDelegate.upload(url)
                            }
                            else {
                                // TODO: Ask user if they really want to upload a big file
                            }
                        }
                    }
                    catch {
                    }
                }
            }
        }
        
        return true
    }
}
