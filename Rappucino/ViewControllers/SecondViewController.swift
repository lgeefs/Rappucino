//
//  SecondViewController.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-05-31.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class SecondViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let recs = self.getRecordings()
        
        DispatchQueue.main.async {
            self.label.text = recs.first?.name ?? "hello"
            for i in 0..<recs.count {
                print(recs[i])
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    private func getRecordings() -> [FinishedRecording] {
        
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
        
        return recordings
        
    }

}

