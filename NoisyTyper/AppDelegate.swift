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
    var soundKey:[AVAudioPlayer?] = []

    var menuItem:NSStatusItem? = nil
    
    func createMenu(){
        self.menuItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        self.menuItem?.title = ""
        let image = NSImage(named: "menuItem.tiff")
        image?.template = true
        self.menuItem?.image = image
        self.menuItem?.highlightMode = true
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "🔊 ↑", action: Selector("upVolume"), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "🔉 ↓", action: Selector("downVolume"), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title:"👋🏼 Bye", action: Selector("exit"), keyEquivalent:""))
        self.menuItem?.menu = menu
    }
    func upVolume(){
        
    }
    func downVolume(){
        
    }
    func exit(){
        NSApp.terminate(nil)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        self.createMenu()
        self.loadSounds()
        NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) { (event) -> Void in
            self.keyWasPressedFunction(event)
        }
    }
    func loadSound(name:String)->AVAudioPlayer?{
        var soundURL:NSURL?
        soundURL = NSBundle.mainBundle().URLForResource(name, withExtension: "mp3")
        var player:AVAudioPlayer?
        if let url = soundURL{
            do {
                player = try AVAudioPlayer(contentsOfURL: url)
            }catch {
                
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
            scrollDn?.play()
        }
        else if( key == 126 ){
            scrollUp?.pan = -0.7
            scrollUp?.rate = Float.random(0.85, 1.0)
            scrollUp?.play()
        }
        else if( key == 51 ){
            backspace?.pan = 0.75
            backspace?.rate = Float.random(0.97, 1.03)
            backspace?.play()
        }
        else if( key == 49 ){
            soundSpace?.pan = Float.random(0.95, 1.05)
            soundSpace?.volume = Float.random(0.8, 1.1)
            soundSpace?.play()

        }
        else if( key == 36 ){
            soundReturn?.pan = 0.3
            soundReturn?.rate = Float.random(0.99, 1.01)
            soundReturn?.volume = Float.random(0.7, 1.1)
            soundReturn?.play();
        }
        else{
            let which = Int.random(0, soundKey.count - 1)
            soundKey[which]?.rate =  Float.random(0.98, 1.02)
            soundKey[which]?.volume = Float.random(0.7, 1.1)
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ){
                soundKey[which]?.pan = -0.65
            }else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ){
                soundKey[which]?.pan = 0.65
            }
            else{
                soundKey[which]?.pan = Float.random(-0.3, 0.3)
            }
            soundKey[which]?.play()
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}
public extension Float {
    public static func random(lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}
public extension Int {
    public static func random(lower: Int = 0, _ upper: Int = 100) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}


