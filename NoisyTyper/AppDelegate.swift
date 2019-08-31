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
    
    var currentTheme:String? = "Typer I"
    var themeItem1:NSMenuItem = NSMenuItem(title:"Typer I", action: #selector(changeTheme), keyEquivalent:"")
    var themeItem2:NSMenuItem = NSMenuItem(title:"Typer II", action: #selector(changeTheme), keyEquivalent:"")
    var themeItem3:NSMenuItem = NSMenuItem(title:"iPhone", action: #selector(changeTheme), keyEquivalent:"")
    
    var functionsKeyTempPool:[AVAudioPlayer?] = []
    
    var soundKey:[AVAudioPlayer?] = []

    var menuItem:NSStatusItem? = nil
    
    var volumeLevel:Float = 1.0
    
    func createMenu(){
        self.menuItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.menuItem?.title = ""
        let image = NSImage(named: NSImage.Name(rawValue: "menuItem"))
        image?.isTemplate = true
        self.menuItem?.image = image
        self.menuItem?.highlightMode = true
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "🔈", action: nil, keyEquivalent: ""))
        let soundSliderItem = NSMenuItem()
        let soundSliderView = NSSlider()
        soundSliderView.setFrameSize(NSSize(width: 160, height: 30))
        soundSliderItem.title = "Slider"
        soundSliderItem.view = soundSliderView
        soundSliderView.maxValue = 1.0
        soundSliderView.minValue = 0.0
        soundSliderView.isContinuous = true
        soundSliderView.target = self
        soundSliderView.action = #selector(configVolume)
        soundSliderView.floatValue = self.volumeLevel
        menu.addItem(soundSliderItem)
        menu.addItem(NSMenuItem.separator())
        
        
        let themeMenuItem = NSMenuItem(title: "🎼", action: nil, keyEquivalent: "")
        menu.addItem(themeMenuItem)
        
        menu.addItem(themeItem1)
        menu.addItem(themeItem2)
        menu.addItem(themeItem3)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title:"❌", action: #selector(exit), keyEquivalent:""))

        self.menuItem?.menu = menu
    }
    

    func applicationDidFinishLaunching(_ notification: Notification) {
        if self.acquirePrivileges() {
            self.startup()
        }
    }
    
    func startup(){
        self.loadVolume()
        self.loadSounds()
        
        self.createMenu()
        self.updateTheme()
        
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event) -> Void in
            self.keyWasPressedFunction(event: event)
        }

    }
    func loadVolume(){
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
    
    func clearSounds() {
        scrollDn = nil
        scrollUp = nil
        backspace = nil
        soundSpace = nil
        soundReturn = nil
        soundKey.removeAll()
    }
    func loadSounds(){
        if let cacheTheme = UserDefaults.standard.string(forKey: "NoisyTyperUserSettings-Theme"){
            self.currentTheme = cacheTheme
        }
        
        
        clearSounds()
        switch self.currentTheme {
        case "Typer I":
            loadSoundsTheme1()
            break;
        case "Typer II":
            loadSoundsTheme2()
            break;
        case "iPhone":
            loadSoundsTheme3()
            break;
        default:
            break;
        }
        playTestSound()
    }
    
    func loadSoundsTheme1(){
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
    
    func loadSoundsTheme2(){
        scrollDn = loadSound("scrollDown")
        scrollUp = loadSound("scrollUp")
        backspace = loadSound("backspace")
        soundSpace = loadSound("space")
        soundReturn = loadSound("return")
        soundKey.append(loadSound("key-01"))
        soundKey.append(loadSound("key-02"))
        soundKey.append(loadSound("key-03"))
        soundKey.append(loadSound("key-04"))
    }
    
    func loadSoundsTheme3(){
        scrollDn = loadSound("KeypressStandard")
        scrollUp = loadSound("KeypressStandard")
        backspace = loadSound("KeypressDelete")
        soundSpace = loadSound("KeypressSpacebar")
        soundReturn = loadSound("KeypressReturn")
        soundKey.append(loadSound("KeypressStandard"))
        soundKey.append(loadSound("KeypressStandard"))
        soundKey.append(loadSound("KeypressStandard"))
        soundKey.append(loadSound("KeypressStandard"))
        soundKey.append(loadSound("KeypressStandard"))
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
        UserDefaults.standard.set(volumeLevel, forKey: "NoisyTyperUserSettings-VolumeLevel")
        UserDefaults.standard.synchronize()
    }
    
    @objc func changeTheme(target:NSMenuItem){
        themeItem1.state = .off
        themeItem2.state = .off
        themeItem3.state = .off
        self.currentTheme = target.title
        updateTheme()
        loadSounds()
        self.playTestSound()
    }
    
    func updateTheme(){
        UserDefaults.standard.set(currentTheme, forKey: "NoisyTyperUserSettings-Theme")
        UserDefaults.standard.synchronize()
        switch self.currentTheme {
        case "Typer I":
            themeItem1.state = .on
            break
        case "Typer II":
            themeItem2.state = .on
            break
        case "iPhone":
            themeItem3.state = .on
            break
        default:
            themeItem1.state = .on
            break;
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



