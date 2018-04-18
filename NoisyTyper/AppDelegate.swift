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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var scrollDn:AVAudioPlayer? = nil
    var scrollUp:AVAudioPlayer? = nil
    var backspace:AVAudioPlayer? = nil
    var soundSpace:AVAudioPlayer? = nil
    var soundReturn:AVAudioPlayer? = nil
    
    var functionsKeyTempPool:[AVAudioPlayer?] = []
    
    var soundKey:[AVAudioPlayer?] = []

    var menuItem:NSStatusItem? = nil
    
    var volumeLevel:Float = 1.0
    var isMuted:Bool = false
    
    func createMenu(){
        self.menuItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.menuItem?.title = ""
        let image = NSImage(named: NSImage.Name(rawValue: "menuItem"))
        image?.isTemplate = true
        self.menuItem?.image = image
        self.menuItem?.highlightMode = true
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "🔊 ↑", action: #selector(upVolume), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "🔇 -", action: #selector(mute), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "🔉 ↓", action: #selector(downVolume), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title:"👋🏼 Bye", action: #selector(exit), keyEquivalent:""))
        self.menuItem?.menu = menu
    }
    

    func applicationDidFinishLaunching(_ notification: Notification) {
        if self.acquirePrivileges() {
            self.startup()
        }
    }
    
    func startup(){
        self.loaddVolume()
        
        self.createMenu()
        self.loadSounds()
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) -> Void in
            self.keyWasPressedFunction(event: event)
        }

    }
    func loaddVolume(){
        self.volumeLevel = UserDefaults.standard.float(forKey: "NoisyTyperUserSettings-VolumeLevel")
        if self.volumeLevel == 0 {
            self.volumeLevel = 1.0
        }
    }
    func loadSound(_ name:String)->AVAudioPlayer? {
        var player:AVAudioPlayer?
        if let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
            } catch {
                print("initiate player for sound \(name) failed")
            }
        }
        return player
    }
    func loadSounds(){
        scrollDn = loadSound("scrollDown")
        scrollUp = loadSound("scrollUp")
        backspace = loadSound("backspace")
        soundSpace = loadSound("space-new")
        soundReturn = loadSound("return-new")
        soundKey.append(loadSound("key-new-01"))
        soundKey.append(loadSound("key-new-02"))
        soundKey.append(loadSound("key-new-03"))
        soundKey.append(loadSound("key-new-04"))
        soundKey.append(loadSound("key-new-05"))
    }
    func keyWasPressedFunction(event:NSEvent){
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
    @objc func mute(){
        self.isMuted = !self.isMuted
        let menuItem = self.menuItem?.menu?.item(at: 1)
        if self.isMuted{
            menuItem?.title = "🔈 +"
        }else{
            menuItem?.title = "🔇 -"
            self.playOpenSound()
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

    func updateVolume(){
        UserDefaults.standard.set(volumeLevel, forKey: "NoisyTyperUserSettings-VolumeLevel")
        UserDefaults.standard.synchronize()
        self.playTestSound()
    }
    @objc func upVolume(){
        volumeLevel = volumeLevel + 0.1
        self.updateVolume()
    }
    @objc func downVolume(){
        volumeLevel = volumeLevel - 0.1
        if (volumeLevel - 0.4) > 0{
            self.updateVolume()
        }else{
            self.loaddVolume()
        }
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



