//
//  ThemeManager.swift
//  NoisyTyper
//
//  Created by iAladdin on 2019/9/18.
//  Copyright © 2019 Aladdin. All rights reserved.
//

import Cocoa

class ThemeMananger {
    static let shared = ThemeMananger()
    var themesInfo:[String:AnyObject]! = nil
    var themes:[[String:AnyObject]]! = nil
    
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
    
    func configThemesUI(_ menu:NSMenu){
        
    }
}
