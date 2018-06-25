//
//  Squad.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-22.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation

class Squad {
    
    private var name: String!
    private var rappers: [Rapper]!
    private var picture_url: URL?
    private var last_update: (String, String)?
    
    init(rappers: [Rapper], name: String, picture_url: URL?) {
        self.rappers = rappers
        self.name = name
        self.picture_url = picture_url
    }
    
    func addRapper(rapper: Rapper) {
        self.rappers.append(rapper)
    }
    
    func getRappers() -> [Rapper] {
        return self.rappers
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func getName() -> String {
        return self.name
    }
    
    func setPicture(url: URL) {
        self.picture_url = url
    }
    
    func getPictureURL() -> URL? {
        return self.picture_url
    }
    
    func getLastUpdate() -> (String, String) {
        return last_update ?? ("Tap to view more details", "")
    }
    
}
