//
//  Rapper.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-22.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation

class Rapper {
    
    private let id: String!
    private let name: String!
    private let handle: String!
    private let picture_url: URL!
    
    init(id: String, name: String, handle: String, picture_url: URL) {
        self.id = id
        self.name = name
        self.handle = handle
        self.picture_url = picture_url
    }
    
}
