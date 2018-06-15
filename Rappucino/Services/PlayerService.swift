//
//  PlayerService.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-11.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlayerServiceDelegate {
    func finishedPlaying()
    func recordingInterrupted()
}

class PlayerService: NSObject, AVAudioPlayerDelegate {
    
    static let shared = PlayerService()
    
    var player: AVAudioPlayer!
    
    var currentRecording: RawRecording!
    
    var delegate: PlayerServiceDelegate?
    
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteDidChange(notification:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        
    }
    
    func play(recording: RawRecording) {
        
        if currentRecording == nil || recording != currentRecording {
            if let delegate = delegate { delegate.recordingInterrupted() }
            currentRecording = recording
            self.setupPlayer()
            return
        }
        
        if player != nil {
            if player.isPlaying {
                player.pause()
            } else {
                player.play()
            }
        } else {
            self.setupPlayer()
        }
        
    }
    
    func pause() {
        if player != nil {
            if player.isPlaying {
                player.pause()
            }
        }
    }
    
    @objc dynamic fileprivate func audioSessionRouteDidChange(notification: Notification) {
        
        print("AVAudioSessionRouteDidChange notification received")
        
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error {
                print(error.localizedDescription)
            }
            break
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error {
                print(error.localizedDescription)
            }
            break
        default:
            break
        }
        
    }
    
    fileprivate func setupPlayer() {
        
        let session = AVAudioSession.sharedInstance()
        
        /*
        
        var headphonesPluggedIn = false
        
        let currentRoute = session.currentRoute
        
        if currentRoute.outputs.count != 0 {
            for desc in currentRoute.outputs {
                if desc.portType == AVAudioSessionPortHeadphones {
                    headphonesPluggedIn = true
                }
            }
        }
 
        */
        
        do {
            
            /*
             
            if !headphonesPluggedIn {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            }
             
            */
 
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            
            try session.setActive(true)
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: currentRecording.url)
            player.delegate = self
            player.volume = 1.0
            player.prepareToPlay()
            player.play()
            FirebaseAnalyticsManager.shared.recordingPlayed(duration: currentRecording.duration, recordingName: currentRecording.name)
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Player finished playing. Successfully=\(flag)")
        if let delegate = delegate {
            delegate.finishedPlaying()
        }
    }
    
}
