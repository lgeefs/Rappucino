//
//  FirebaseAnalyticsManager.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-12.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAnalytics

class FirebaseAnalyticsManager {
    
    static let shared = FirebaseAnalyticsManager()
    
    func configure() {
        FirebaseApp.configure()
    }
    
    private func log(_ name: String, _ parameters: [String: NSObject]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    func soundbiteSaved(duration: Double, numberOfBits: Int, soundbiteName: String) {
        
        log("SoundbiteSaved", ["Duration":duration as NSObject, "NumberOfBits":numberOfBits as NSObject, "SoundbiteName":soundbiteName as NSObject])
        
    }
    
    func soundbiteDeleted() {
        
        log("SoundbiteDeleted", [:])
        
    }
    
    func soundbitePlayed(duration: Double, soundbiteName: String?) {
        
        log("SoundbitePlayed", ["Duration":duration as NSObject, "SoundbiteName":soundbiteName as NSObject? ?? "nil" as NSObject])
        
    }
    
}
