//
//  Squad.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-22.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation

class Squad {
    
    private var id: String!
    private var name: String!
    private var rappers: [Rapper]!
    private var picture_url: URL?
    private var last_update: (String, String)?
    
    init(id: String, name: String, picture_url: String) {
        self.id = id
        self.name = name
        self.picture_url = URL(string: picture_url) ?? nil
    }
    
    func getId() -> String {
        return self.id
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
