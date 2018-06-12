//
//  RawRecording.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-05.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import AVFoundation

class RawRecording {
    
    var asset: AVAsset {
        get {
            return AVAsset(url: self.url)
        }
    }
    var name: String!
    var duration: Double {
        get {
            return AVAsset(url: self.url).duration.seconds
        }
    }
    var creationDate: Date!
    var url: URL!
    
    var new: Bool! {
        get {
            if let value = UserDefaults.standard.value(forKey: "\(self.name!)isnew") as? Bool {
                return value
            } else {
                return false
            }
        }
    }
    
    var currentTime: Double! {
        get {
            if PlayerService.shared.player != nil && PlayerService.shared.currentRecording == self {
                return PlayerService.shared.player.currentTime
            } else {
                return 0
            }
        }
    }
    
    var isPlaying: Bool {
        get {
            if PlayerService.shared.currentRecording != nil && PlayerService.shared.currentRecording == self {
                if PlayerService.shared.player != nil {
                    if PlayerService.shared.player.isPlaying {
                        return true
                    }
                }
            }
            return false
        }
    }
    
}


func ==(lhs: RawRecording, rhs: RawRecording) -> Bool {
    if lhs.duration != rhs.duration { return false }
    if lhs.url != rhs.url { return false }
    return true
}

func !=(lhs: RawRecording, rhs: RawRecording) -> Bool {
    return !(lhs == rhs)
}
