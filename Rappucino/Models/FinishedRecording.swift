//
//  Recording.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-11.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation

class FinishedRecording: RawRecording {
    
    init(_ name: String, _ creationDate: Date, _ url: URL) {
        super.init()
        
        self.name = name.replacingOccurrences(of: "%20", with: " ")
        self.creationDate = creationDate
        self.url = url
        
    }
    
}
