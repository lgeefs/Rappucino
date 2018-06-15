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
    
    func recordingSaved(duration: Double, numberOfClips: Int, recordingName: String) {
        
        log("RecordingSaved", ["Duration":duration as NSObject, "NumberOfClips":numberOfClips as NSObject, "RecordingName":recordingName as NSObject])
        
    }
    
    func recordingDeleted(recordingName: String) {
        
        log("RecordingDeleted", ["RecordingName":recordingName as NSObject])
        
    }
    
    func recordingPlayed(duration: Double, recordingName: String?) {
        
        log("RecordingPlayed", ["Duration":duration as NSObject, "RecordingName":recordingName as NSObject? ?? "nil" as NSObject])
        
    }
    
}
