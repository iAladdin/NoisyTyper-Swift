//
//  AVAudioPlayer-extensions.swift
//  NoisyTyper
//
//  Created by Aladdin on 15/12/8.
//  Copyright © 2015年 Aladdin. All rights reserved.
//

import AVFoundation
import AppKit

extension AppDelegate:AVAudioPlayerDelegate{

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        autoreleasepool {
            player.stop()
            var indexOfPlayer = LONG_MAX as Int
            var index = 0 as Int
            var tempArray = Array(self.functionsKeyTempPool)
            for item in tempArray{
                if item == player {
                    indexOfPlayer = index
                    self.functionsKeyTempPool.remove(at: indexOfPlayer)
                }
                index = index + 1
            }
            tempArray.removeAll()
        }
    }
}

extension AVAudioPlayer{
    public func playNoisy(){
        let appDelegate = NSApp.delegate as! AppDelegate
        if appDelegate.volumeLevel == 0.0 {
            return
        }else{
            if self.isPlaying{
                if self.duration > 1.0 {
                    if self.currentTime  > 0.1 {
                        self.currentTime = 0
                        self.play()
                    }
                }else{
                    if let url = self.url{
                        autoreleasepool {
                            var tempPlayer:AVAudioPlayer?
                            if appDelegate.functionsKeyTempPool.count > 30{
                                return
                            }
                            do {
                                tempPlayer = try AVAudioPlayer(contentsOf: url)
                                appDelegate.functionsKeyTempPool.append(tempPlayer)
                                tempPlayer?.pan = self.pan
                                tempPlayer?.volume = self.volume
                                tempPlayer?.rate = self.rate
                                tempPlayer?.delegate = appDelegate
                                tempPlayer?.play()
                                tempPlayer = nil
                            }catch{
                                print("error")
                            }
                        }
                    }
                }
            }else{
                self.play()
            }
        }
    }
}
