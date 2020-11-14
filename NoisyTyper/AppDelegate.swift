//
//  AppDelegate.swift
//  NoisyTyper
//
//  Created by Aladdin on 15/12/7.
//  Copyright © 2015年 Aladdin. All rights reserved.
//

import Cocoa
import AVFoundation
import Darwin
import SnapKit



let kThemeKey = "ConfigThemeKey"
let kSoundVolume = "ConfigSoundVolumeKey"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var configWC:NTWindowController?
    
    var themeItems:[NSMenuItem] = []
    
    var menuItem:NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if self.acquirePrivileges() {
            self.startup()
        }
    }
    
    func startup(){
        ThemeMananger.shared.loadThemes()
        ThemeMananger.shared.changeToTheme(UserDefaults.standard.integer(forKey: kThemeKey))
        ThemeMananger.shared.loadSoundsByCurrentConfig()
        ThemeMananger.shared.loadVolume()
        
        self.createMenu()
        self.updateTheme()
        
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) -> Void in
            ThemeMananger.shared.keyWasPressedFunction(event: event)
        }

    }
    
    func composeMenuFromThemes(_ menu:NSMenu){
        for (index,theme) in ThemeMananger.shared.themes.enumerated() {
            let themeName = theme["displayName"] as! String
            let item = createSFXItem(title:themeName , tag: index, selector: #selector(newChangeTheme))
            self.themeItems.append(item)
            menu.addItem(item)
        }
    }

}

//Utils
extension AppDelegate{
    
    @objc func exit(){
        NSApp.terminate(nil)
    }
    
    @objc func showStore(){
        if(self.configWC == nil){
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            self.configWC = (storyboard.instantiateController(withIdentifier: "Store") as! NSWindowController as! NTWindowController)
        }
        if let storeWindow = self.configWC?.window {
            storeWindow.makeKeyAndOrderFront(self)
            self.updateStoreStyle()
        }
        NSApp.activate(ignoringOtherApps: true)
        
    }
    
    func updateStoreStyle() {
        if(self.configWC != nil){
            if let storeWindow = self.configWC?.window {
                for themeID in 0..<self.themeItems.count {
                    if let buttonView = storeWindow.contentView?.viewWithTag(themeID){
                        let button:NSButton = buttonView as! NSButton
                        let buttonTitleColor:NSColor = ThemeMananger.shared.currentThemeID == themeID ? NSColor.white : NSColor.disabledControlTextColor
                        if let mutableAttributedTitle = button.attributedTitle.mutableCopy() as? NSMutableAttributedString {
                            mutableAttributedTitle.addAttribute(.foregroundColor, value: buttonTitleColor, range: NSRange(location: 0, length: mutableAttributedTitle.length))
                            button.attributedTitle = mutableAttributedTitle
                        }
                    }
                }
            }
        }
    }





    @objc func configVolume(slider:NSSlider){
        ThemeMananger.shared.configVolume(slider: slider)
        let event = NSApplication.shared.currentEvent
        if event?.type == NSEvent.EventType.leftMouseUp {
            self.updateVolume()
        }
    }
    
    func updateVolume(){
        UserDefaults.standard.set(ThemeMananger.shared.volumeLevel, forKey: kSoundVolume)
        UserDefaults.standard.synchronize()
    }
    
    @objc func newChangeTheme(target:NSMenuItem) {
        ThemeMananger.shared.newChangeTheme(target:target)
        self.updateTheme()
        self.updateStoreStyle()
    }
    
    func newChangeThemeFromStore(target:NSButton) {
        ThemeMananger.shared.newChangeThemeFromStore(target:target)
        self.updateTheme()
        self.updateStoreStyle()
    }
    
    
    
    func updateTheme(){
        for item in self.themeItems {
            if item.tag == ThemeMananger.shared.currentThemeID {
                item.state = .on
            }else{
                item.state = .off
            }
        }
        UserDefaults.standard.set(ThemeMananger.shared.currentThemeID, forKey: kThemeKey)
        UserDefaults.standard.synchronize()
    }

    func acquirePrivileges() -> Bool {
        let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let privOptions = [String(trusted): true]
        let accessEnabled = AXIsProcessTrustedWithOptions(privOptions as CFDictionary)
        if accessEnabled != true {
            let alert = NSAlert()
            alert.messageText = "Enable NoisyTyper Using Accessibility feature"
            alert.informativeText = "Once you have enabled NoisyTyper in System Preferences->Security and Privacy -> Privacy, click OK."
            NSRunningApplication.current.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
            let response = alert.runModal()
            if (response == NSApplication.ModalResponse.cancel) {
                if AXIsProcessTrustedWithOptions(privOptions as CFDictionary) == true {
                    self.startup()
                } else {
                    NSApp.terminate(self)
                }
            }
        }
        return accessEnabled == true
    }
}


