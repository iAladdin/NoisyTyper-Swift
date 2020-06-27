//
//  NTViewController.swift
//  NoisyTyper
//
//  Created by iAladdin on 2019/9/15.
//  Copyright © 2019 Aladdin. All rights reserved.
//

import Cocoa

class NTViewController: NSViewController{
    
    @IBAction func changeThemeFromStore(_ target:NSButton){
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.newChangeThemeFromStore(target: target)
    }

}


