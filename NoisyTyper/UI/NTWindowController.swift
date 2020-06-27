//
//  NTWindow.swift
//  NoisyTyper
//
//  Created by iAladdin on 2019/9/13.
//  Copyright © 2019 Aladdin. All rights reserved.
//

import Cocoa

class NTWindowController: NSWindowController{
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
        window?.styleMask.insert(.fullSizeContentView)
        window?.titlebarAppearsTransparent = true
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.contents = NSImage(named: "background")
    }
}
