//
//  UIHelper.swift
//  NoisyTyper
//
//  Created by iAladdin on 2019/9/13.
//  Copyright © 2019 Aladdin. All rights reserved.
//

import Cocoa

func createVolumeItem(target:AnyObject,selector:Selector,volumeLevel:Float)->NSMenuItem {
    let soundSliderItem = NSMenuItem()
    let sliderContainerView = NSView()
    
    let soundSliderView = NSSlider()
    soundSliderView.setFrameSize(NSSize(width: 160, height: 30))
    soundSliderView.maxValue = 1.0
    soundSliderView.minValue = 0.0
    soundSliderView.isContinuous = true
    soundSliderView.target = target
    soundSliderView.action = selector
    soundSliderView.floatValue = volumeLevel
    
    sliderContainerView.addSubview(soundSliderView)
    soundSliderView.snp.makeConstraints { (make) in
        make.left.equalTo(sliderContainerView).offset(20)
        make.right.equalTo(sliderContainerView).offset(-10)
        make.top.equalTo(sliderContainerView)
        make.bottom.equalTo(sliderContainerView)
    }
    
    sliderContainerView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 140, height: 20))
    sliderContainerView.wantsLayer = true
    
    soundSliderItem.title = "Slider"
    soundSliderItem.view = sliderContainerView
    return soundSliderItem
}

func createSFXItem(title:String,tag:Int,selector:Selector)->NSMenuItem {
    let item = NSMenuItem(title: title, action: selector, keyEquivalent: "")
    item.tag = tag
    return item
}
