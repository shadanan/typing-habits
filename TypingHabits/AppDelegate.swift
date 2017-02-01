//
//  AppDelegate.swift
//  TypingHabits
//
//  Created by Shad Sharma on 12/13/16.
//  Copyright © 2016 Shad Sharma. All rights reserved.
//

import Cocoa

func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    
    let leftShiftOnly = 131330 as UInt64
    let rightShiftOnly = 131332 as UInt64
    
    if type == .keyDown {
        let keyCode = KeyCode.from(CGEvent: event)
        let flags = event.flags.rawValue
        
        if flags == leftShiftOnly && "QWERTASDFGZXCVB".contains(keyCode.character) {
            let notification = NSUserNotification()
            notification.title = "TypingHabits Blocked \(keyCode)"
            NSUserNotificationCenter.default.deliver(notification)
            return nil
        }
        
        
        if flags == rightShiftOnly && "YUIOPHJKLNM".contains(keyCode.character) {
            let notification = NSUserNotification()
            notification.title = "TypingHabits Blocked \(keyCode)"
            NSUserNotificationCenter.default.deliver(notification)
            return nil
        }
    }
    
    return Unmanaged.passRetained(event)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let statusImageOn = NSImage(named: "StatusItemOn")!
    let statusImageOff = NSImage(named: "StatusItemOff")!
    var eventTap: CFMachPort!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusImageOn.size = NSMakeSize(20, 20)
        statusImageOff.size = NSMakeSize(20, 20)

        if let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue), callback: eventCallback, userInfo: nil) {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.eventTap = eventTap
            disable()
        } else {
            let alert = NSAlert()
            alert.messageText = "TypingHabits requires permission to use Accessibility features."
            alert.informativeText = "To proceed, you will need to give TypingHabits permission to use Accessibility. Click the Grant Access button and you will be presented with a dialog that takes you to System Preferences. After granting access, relaunch TypingHabits."
            alert.addButton(withTitle: "Grant Access")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == 1000 {
                let options = NSDictionary(object: kCFBooleanTrue, forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString) as CFDictionary
                AXIsProcessTrustedWithOptions(options)
            }
            
            NSApp.terminate(self)
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle", action: #selector(self.toggle), keyEquivalent: "t"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    func toggle() {
        if CGEvent.tapIsEnabled(tap: eventTap) {
            disable()
        } else {
            enable()
        }
    }
    
    func enable() {
        statusItem.image = statusImageOn
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    func disable() {
        statusItem.image = statusImageOff
        CGEvent.tapEnable(tap: eventTap, enable: false)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

