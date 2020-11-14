//
//  AppMenuUI.swift
//  NoisyTyper
//
//  Created by iAladdin on 2019/9/19.
//  Copyright © 2019 Aladdin. All rights reserved.
//

import Cocoa

extension AppDelegate{
    func createMenu(){
        self.menuItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.menuItem?.title = ""
        let image = NSImage(named: "menuItem")
        image?.isTemplate = true
        self.menuItem?.image = image
        self.menuItem?.highlightMode = true
        
        let menu = NSMenu()
        // Version Info
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let nsObject = Bundle.main.infoDictionary?["CFBundleVersion"] as? String{
                menu.addItem(NSMenuItem(title:"NoisyTyper Version:\(String(describing: appVersion))(\(String(describing: nsObject)))", action: nil, keyEquivalent:""))
            }
        }
        
        menu.addItem(NSMenuItem(title: "Volume", action: nil, keyEquivalent: ""))
        let soundSliderItem = createVolumeItem(target: self,selector: #selector(configVolume),volumeLevel: ThemeMananger.shared.volumeLevel)
        menu.addItem(soundSliderItem)
        menu.addItem(NSMenuItem.separator())
        
        
        let themeMenuItem = NSMenuItem(title: "SFX Themes", action: nil, keyEquivalent: "")
        menu.addItem(themeMenuItem)
        
        composeMenuFromThemes(menu)
    
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title:"Gallery", action: #selector(showStore), keyEquivalent:","))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title:"Quit", action: #selector(exit), keyEquivalent:""))
        self.menuItem?.menu = menu
    }
}
