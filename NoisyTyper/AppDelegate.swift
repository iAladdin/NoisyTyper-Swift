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
    
    var configWC:NTWindowController? = nil

    var scrollDn:AVAudioPlayer? = nil
    var scrollUp:AVAudioPlayer? = nil
    var backspace:AVAudioPlayer? = nil
    var soundSpace:AVAudioPlayer? = nil
    var soundReturn:AVAudioPlayer? = nil

    var currentThemeID:Int = 0
    
    
    var themeItems:[NSMenuItem] = []
    
    var functionsKeyTempPool:[AVAudioPlayer?] = []
    
    var soundKey:[AVAudioPlayer?] = []

    var menuItem:NSStatusItem? = nil
    
    var volumeLevel:Float = 1.0
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if self.acquirePrivileges() {
            self.startup()
        }
    }
    
    func startup(){
        self.currentThemeID = UserDefaults.standard.integer(forKey: kThemeKey)
        
        ThemeMananger.shared.loadThemes()
        self.loadVolume()
        
        self.loadSoundsByCurrentConfig()
        self.createMenu()
        self.updateTheme()
        
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) -> Void in
            self.keyWasPressedFunction(event: event)
        }

    }
    
    func loadThemes(_ menu:NSMenu){
        for (index,theme) in ThemeMananger.shared.themes.enumerated() {
            let themeName = theme["displayName"] as! String
            let item = createSFXItem(title:themeName , tag: index, selector: #selector(newChangeTheme))
            self.themeItems.append(item)
            menu.addItem(item)
        }
    }
    
    func loadVolume(){
        self.volumeLevel = UserDefaults.standard.float(forKey: kSoundVolume)
    }
    
    func loadSound(_ theme:String, name:String)->AVAudioPlayer? {
        var player:AVAudioPlayer?
        if let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3",subdirectory: "SFX/\(theme)") {
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
            } catch {
                print("initiate player for sound \(name) failed")
            }
        }
        return player
    }
    
    func clearSounds() {
        scrollDn = nil
        scrollUp = nil
        backspace = nil
        soundSpace = nil
        soundReturn = nil
        soundKey.removeAll()
    }
    
    func loadSoundsByCurrentConfig(){
        clearSounds()
        let themeInfo = ThemeMananger.shared.themes[self.currentThemeID]
        let themePath = themeInfo["path"] as! String
        scrollDn = loadSound(themePath,name: themeInfo["scrollDownKey"] as! String)
        scrollUp = loadSound(themePath,name: themeInfo["scrollUpKey"] as! String)
        backspace = loadSound(themePath,name: themeInfo["backspaceKey"] as! String)
        soundSpace = loadSound(themePath,name: themeInfo["spaceKey"] as! String )
        soundReturn = loadSound(themePath,name: themeInfo["returnKey"] as! String)
        let basicKeyList = themeInfo["basicKey"] as! [String]
        for basicKey in basicKeyList {
            soundKey.append(loadSound(themePath,name: basicKey))
        }
        playTestSound()
    }
    
    func keyWasPressedFunction(event:NSEvent){
        
        if(self.volumeLevel == 0){
            return
        }
        
        let key = event.keyCode
        
        if( key == 125 ){
            scrollDn?.pan = 0.7
            scrollDn?.rate = Float.random(0.85, 1.0)
            scrollDn?.volume = self.volumeLevel
            scrollDn?.playNoisy()
        }
        else if( key == 126 ){
            scrollUp?.pan = -0.7
            scrollUp?.rate = Float.random(0.85, 1.0)
            scrollUp?.volume = self.volumeLevel
            scrollUp?.playNoisy()
        }
        else if( key == 51 ){
            backspace?.pan = 0.75
            backspace?.rate = 0.97
            backspace?.volume = self.volumeLevel
            backspace?.playNoisy()
        }
        else if( key == 49 ){
            soundSpace?.pan = Float.random(-0.2, 0.2)
            soundSpace?.volume = Float.random(self.volumeLevel - 0.3, self.volumeLevel)
            soundSpace?.playNoisy()

        }
        else if( key == 36 ){
            soundReturn?.pan = 0.5
            soundReturn?.rate = Float.random(0.99, 1.01)
            soundReturn?.volume = Float.random(self.volumeLevel - 0.4, self.volumeLevel)
            soundReturn?.playNoisy()
        }
        else{
            let freeKeyplayer = self.findFreeKeyplayer()
            freeKeyplayer?.rate =  Float.random(0.98, 1.02)
            freeKeyplayer?.volume = Float.random(self.volumeLevel - 0.4, self.volumeLevel)
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ){
                freeKeyplayer?.pan = -0.65
            }else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ){
                freeKeyplayer?.pan = 0.65
            }
            else{
                freeKeyplayer?.pan = Float.random(-0.3, 0.3)
            }
            freeKeyplayer?.play()
        }
    }
    func findFreeKeyplayer()->AVAudioPlayer?{
        var result: AVAudioPlayer? = nil
        repeat {
            let which = Int.random(0, soundKey.count - 1)
            result = soundKey[which]
            
        }while (result?.isPlaying == true)
        return result
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
                        let buttonTitleColor:NSColor = self.currentThemeID == themeID ? NSColor.white : NSColor.disabledControlTextColor;
                        if let mutableAttributedTitle = button.attributedTitle.mutableCopy() as? NSMutableAttributedString {
                            mutableAttributedTitle.addAttribute(.foregroundColor, value: buttonTitleColor, range: NSRange(location: 0, length: mutableAttributedTitle.length))
                            button.attributedTitle = mutableAttributedTitle
                        }
                    }
                }
            }
        }
    }

    func playTestSound(){
        soundKey[0]?.pan = 0.3
        soundKey[0]?.volume = self.volumeLevel
        soundKey[0]?.playNoisy()
    }

    func playOpenSound(){
        soundReturn?.pan = 0.3
        soundReturn?.rate = Float.random(0.99, 1.01)
        soundReturn?.volume = Float.random(self.volumeLevel - 0.4, self.volumeLevel)
        soundReturn?.playNoisy()
    }

    @objc func configVolume(slider:NSSlider){
        if volumeLevel != slider.floatValue {
            volumeLevel = slider.floatValue
        }
        let event = NSApplication.shared.currentEvent
        if event?.type == NSEvent.EventType.leftMouseUp {
            self.updateVolume()
            self.playTestSound()
        }
    }
    
    func updateVolume(){
        UserDefaults.standard.set(volumeLevel, forKey: kSoundVolume)
        UserDefaults.standard.synchronize()
    }
    
    @objc func newChangeTheme(target:NSMenuItem) {
        if(self.currentThemeID != target.tag){
            self.currentThemeID = target.tag
            loadSoundsByCurrentConfig()
        }else{
            self.playTestSound()
        }
        self.updateTheme()
        self.updateStoreStyle()
    }
    
    func newChangeThemeFromStore(target:NSButton) {
        if(self.currentThemeID != target.tag){
            self.currentThemeID = target.tag
            loadSoundsByCurrentConfig()
        }else{
            self.playTestSound()
        }
        self.updateTheme()
        self.updateStoreStyle()
    }
    
    
    
    func updateTheme(){
        for item in self.themeItems {
            if item.tag == currentThemeID {
                item.state = .on
            }else{
                item.state = .off
            }
        }
        UserDefaults.standard.set(currentThemeID, forKey: kThemeKey)
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


