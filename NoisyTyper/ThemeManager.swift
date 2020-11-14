//
//  ThemeManager.swift
//  NoisyTyper
//
//  Created by iAladdin on 2019/9/18.
//  Copyright © 2019 Aladdin. All rights reserved.
//

import Cocoa
import AVFoundation

class ThemeMananger :NSObject{
    static let shared = ThemeMananger()
    var themesInfo:[String:AnyObject]! = nil
    var themes:[[String:AnyObject]]! = nil
    var currentThemeID:Int = 0
    var currentTheme:[String:AnyObject]! = nil
    
    var scrollDn:AVAudioPlayer?
    var scrollUp:AVAudioPlayer?
    var backspace:AVAudioPlayer?
    var soundSpace:AVAudioPlayer?
    var soundReturn:AVAudioPlayer?
    var soundKeyPool:[AVAudioPlayer?] = []
    
    var functionsKeyTempPool:[AVAudioPlayer?] = []
    
    var volumeLevel:Float = 1.0
    
    func loadVolume(){
        if((UserDefaults.standard.object(forKey: kSoundVolume)) != nil){
            self.volumeLevel = UserDefaults.standard.float(forKey: kSoundVolume)
        }else{
            self.volumeLevel = 0.5
        }
    }
    
    
    func loadThemes(){
        var tInfo:[String:AnyObject]?
        if let path = Bundle.main.path(forResource: "theme", ofType: "plist", inDirectory: "SFX") {
        
            tInfo = NSDictionary(contentsOfFile: path) as? [String : AnyObject]
        }
        if let aInfo = tInfo{
            self.themesInfo = aInfo
            self.themes = self.themesInfo["ThemeList"] as? [[String:AnyObject]]
        }
    }
    
    func changeToTheme(_ tag:Int){
        if(self.currentThemeID != tag){
            self.currentThemeID = tag
        }
        self.currentTheme = self.themes[self.currentThemeID]
    }
    
    func configThemesUI(_ menu:NSMenu){
        
    }
    
    func clearSounds() {
        scrollDn = nil
        scrollUp = nil
        backspace = nil
        soundSpace = nil
        soundReturn = nil
        soundKeyPool.removeAll()
    }
    
    func loadSoundsByCurrentConfig(){
        clearSounds()
        let themeInfo = self.themes[self.currentThemeID]
        let themePath = themeInfo["path"] as! String
        scrollDn = loadSound(themePath,name: themeInfo["scrollDownKey"] as! String)
        scrollUp = loadSound(themePath,name: themeInfo["scrollUpKey"] as! String)
        backspace = loadSound(themePath,name: themeInfo["backspaceKey"] as! String)
        soundSpace = loadSound(themePath,name: themeInfo["spaceKey"] as! String )
        soundReturn = loadSound(themePath,name: themeInfo["returnKey"] as! String)
        let basicKeyList = themeInfo["basicKey"] as! [String]
        for basicKey in basicKeyList {
            soundKeyPool.append(loadSound(themePath,name: basicKey))
            soundKeyPool.append(loadSound(themePath,name: basicKey))
        }
        playTestSound()
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
    
    func playTestSound(){
        soundKeyPool[0]?.pan = 0.3
        soundKeyPool[0]?.volume = self.volumeLevel
        soundKeyPool[0]?.playNoisy()
    }
    
    @objc func configVolume(slider:NSSlider){
        if volumeLevel != slider.floatValue {
            volumeLevel = slider.floatValue
        }
        let event = NSApplication.shared.currentEvent
        if event?.type == NSEvent.EventType.leftMouseUp {
            self.playTestSound()
        }
    }
    
    @objc func newChangeTheme(target:NSMenuItem) {
        if(self.currentThemeID != target.tag){
            self.currentThemeID = target.tag
            self.currentTheme = self.themes[self.currentThemeID]
            ThemeMananger.shared.loadSoundsByCurrentConfig()
        }else{
            ThemeMananger.shared.playTestSound()
        }
    }
    
    func newChangeThemeFromStore(target:NSButton) {
        if(self.currentThemeID != target.tag){
            self.currentThemeID = target.tag
            self.currentTheme = self.themes[self.currentThemeID]
            ThemeMananger.shared.loadSoundsByCurrentConfig()
        }else{
            ThemeMananger.shared.playTestSound()
        }
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
                scrollUp?.pan = 0.7
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
                let type = self.currentTheme["type"] as! String
                if(type == "physical"){
                    let randomVolumeLevel = Float.random(self.volumeLevel - 0.4 , self.volumeLevel)
                    freeKeyplayer?.volume = randomVolumeLevel < 0.1 ? 0.1 : randomVolumeLevel
                }
    
                if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ){
                    freeKeyplayer?.pan = -0.65
                }else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ){
                    freeKeyplayer?.pan = 0.65
                }
                else{
                    freeKeyplayer?.pan = Float.random(-0.2, 0.2)
                }
                freeKeyplayer?.play()
            }
        }
    
    func findFreeKeyplayer()->AVAudioPlayer?{
        var result: AVAudioPlayer?
        for soundPlayer in soundKeyPool {
            if(soundPlayer?.isPlaying == false){
                result = soundPlayer
            }
        }
        DispatchQueue.global(qos: .background).async {
            self.soundKeyPool.sort { (a, b) -> Bool in
                        if(b?.isPlaying == true && a?.isPlaying == false){
                            return true
                        }
                        if(b?.isPlaying == false && a?.isPlaying == true){
                            return false
                        }
                        return true
                    }
        }
        
        return result
    }
}
