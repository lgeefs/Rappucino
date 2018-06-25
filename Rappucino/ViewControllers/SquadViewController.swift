//
//  SquadViewController.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-22.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import UIKit

class SquadViewController: UIViewController {
    
    var squad: Squad! {
        didSet {
            update()
        }
    }
    
    init(squad: Squad) {
        self.squad = squad
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func update() {
        self.title = squad.getName()
    }
    
}
