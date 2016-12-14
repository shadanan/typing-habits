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
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags.rawValue
        
        print(keyCode)
        
        if flags == leftShiftOnly && [0,1,2,3,5,6,7,8,9,11,12,13,14,15,17].contains(keyCode) {
            let notification = NSUserNotification()
            notification.title = "TypingHabits Blocked Left ⇧\(keyCode)"
            NSUserNotificationCenter.default.deliver(notification)
            return nil
        }
        
        if flags == rightShiftOnly && [4,16,31,32,34,35,37,38,39,40,41,43,44,45,46,47].contains(keyCode) {
            let notification = NSUserNotification()
            notification.title = "TypingHabits Blocked Right ⇧\(keyCode)"
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
    var eventTap : CFMachPort?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusImageOn.size = NSMakeSize(20, 20)
        statusImageOff.size = NSMakeSize(20, 20)
        
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue), callback: eventCallback, userInfo: nil)
        
        guard eventTap != nil else {
            print("Not authorized!")
            exit(1)
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        disable()
        
        statusItem.button!.action = #selector(self.toggle)
    }
    
    func toggle() {
        guard eventTap != nil else {
            return
        }

        if CGEvent.tapIsEnabled(tap: eventTap!) {
            disable()
        } else {
            enable()
        }
    }
    
    func enable() {
        guard eventTap != nil else {
            return
        }

        statusItem.image = statusImageOn
        CGEvent.tapEnable(tap: eventTap!, enable: true)
    }
    
    func disable() {
        guard eventTap != nil else {
            return
        }

        statusItem.image = statusImageOff
        CGEvent.tapEnable(tap: eventTap!, enable: false)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

