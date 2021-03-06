//
//  ThirdViewController.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-22.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ThirdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    
    var squads = [Squad]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = .white
        self.title = "Squads"
        
        Api.shared.get_squads(rapper_id: "lgeefs96") { squads in

            if let squads = squads {
                self.squads = squads
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
        
        tableView.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecordingTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 100
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height*0.75)
        
        view.addSubview(tableView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(createSquad(sender:)))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.rightBarButtonItem = nil
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func createSquad(sender: UIBarButtonItem) {
        
        self.present(SearchResultsViewController(), animated: true, completion: nil)
        
    }
    
    /******************************
     TableView stuff
     ******************************/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch (section) {
        case 0:
            return ""
        case 1:
            return "Pending"
        case 2:
            return "Rivals"
        default:
            return ""            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.squads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SquadTableViewCell
        
        cell.squad = self.squads[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let s = self.squads[indexPath.row]
        
        let vc = SquadViewController(squad: s)
        
        self.show(vc, sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let s = tableView.cellForRow(at: indexPath) as! SquadTableViewCell
            s.deleteButtonPressed(sender: UIButton())
            self.squads.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
}
