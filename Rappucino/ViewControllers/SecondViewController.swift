//
//  SecondViewController.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-05-31.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var label: UILabel!
    
    var tableView = UITableView()
    
    var recordings = [FinishedRecording]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getRecordings()
        layoutUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupUI() {
        
        self.view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecordingTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 100
        
        view.addSubview(tableView)
        
    }
    
    func layoutUI() {
        
        tableView.frame = CGRect(x: 0, y: 20, width: view.bounds.width, height: view.bounds.height-20)
        
    }
    
    private func getRecordings() {
        
        let recordingsDirectory = RecordingService.shared.finishedDirectory!
        
        var recordingURLs = [URL]()
        
        do {
            recordingURLs = try FileManager.default.contentsOfDirectory(at: recordingsDirectory, includingPropertiesForKeys: nil, options: [])
        } catch let error {
            print(error)
        }
        
        var recordings = [FinishedRecording]()
        
        for url in recordingURLs {
            let url = URL(fileURLWithPath: url.path)
            if url.lastPathComponent == ".DS_Store" { continue }
            print("Displaying recording from url: \(url)")
            let asset = AVAsset(url: url)
            let name = url.deletingPathExtension().lastPathComponent
            if asset.duration.seconds == 0 || asset.creationDate == nil { continue }
            let recording = FinishedRecording(name, asset.creationDate!.dateValue!, url)
            
            recordings.append(recording)
        }
        
        recordings.sort(by: { $0.creationDate!.timeIntervalSince1970 > $1.creationDate!.timeIntervalSince1970 })
        
        self.recordings = recordings
        tableView.reloadData()
        
    }
    
    /******************************
    TableView stuff
    ******************************/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordingTableViewCell
        
        cell.recording = self.recordings[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let r = self.recordings[indexPath.row]
        
        PlayerService.shared.play(recording: r)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let r = tableView.cellForRow(at: indexPath) as! RecordingTableViewCell
            r.deleteButtonPressed(sender: UIButton())
            self.recordings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }

}

