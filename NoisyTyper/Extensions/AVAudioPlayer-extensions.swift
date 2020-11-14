//
//  AVAudioPlayer-extensions.swift
//  NoisyTyper
//
//  Created by Aladdin on 15/12/8.
//  Copyright © 2015年 Aladdin. All rights reserved.
//

import AVFoundation
import AppKit

extension ThemeMananger:AVAudioPlayerDelegate{

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        autoreleasepool {
            player.stop()
            var indexOfPlayer = LONG_MAX as Int
            var index = 0 as Int
            var tempArray = Array(ThemeMananger.shared.functionsKeyTempPool)
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
        let tManager = ThemeMananger.shared
        if tManager.volumeLevel == 0.0 {
            return
        }else{
            if self.isPlaying{
                if self.duration > 1.0 {
                    if self.currentTime  > 0.05 {
                        self.currentTime = 0
                        self.play()
                    }
                }else{
                    if let url = self.url{
                        autoreleasepool {
                            var tempPlayer:AVAudioPlayer?
                            if tManager.functionsKeyTempPool.count > 30{
                                return
                            }
                            do {
                                tempPlayer = try AVAudioPlayer(contentsOf: url)
                                tManager.functionsKeyTempPool.append(tempPlayer)
                                tempPlayer?.pan = self.pan
                                tempPlayer?.volume = self.volume
                                tempPlayer?.rate = self.rate
                                tempPlayer?.delegate = tManager
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
