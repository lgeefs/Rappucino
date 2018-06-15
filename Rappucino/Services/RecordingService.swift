//
//  RecorderController.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-05.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import AVFoundation

/*
 
 #FF5F5F
 #FF9C84
 #B16654
 #FFEEEE
 #CBCBCB
 
 */

fileprivate struct DirectoryNames {
    
    static let raw_files = "rawfiles"
    static let clipped_files = "clippedfiles"
    static let finished_files = "finishedfiles"
    
}

protocol MeterDelegate {
    func updateSoundMeter(value: Float)
}

class RecordingService: NSObject, AVAudioRecorderDelegate {
    
    static let shared = RecordingService()
    
    var delegate: MeterDelegate?
    //var meterTimer: Timer!
    
    let fileManager = FileManager.default
    
    var audioRecorder: AVAudioRecorder!
    
    var lastRecordPath: URL!
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var rawDirectory: URL!
    var clipsDirectory: URL!
    var finishedDirectory: URL!
    
    var startDate = Date()
    var clips = [Clip]()
    
    fileprivate lazy var recordingSettings: [String: AnyObject] = {
        
        return [
            
            AVFormatIDKey:             NSNumber(value:kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : NSNumber(value:AVAudioQuality.max.rawValue),
            AVEncoderBitRateKey :      NSNumber(value:320000),
            AVNumberOfChannelsKey:     NSNumber(value:1),
            AVSampleRateKey :          NSNumber(value:44100.0)
            
        ]
        
    }()
    
    private override init() {
        super.init()
        
        rawDirectory = documentsDirectory.appendingPathComponent(DirectoryNames.raw_files)
        clipsDirectory = documentsDirectory.appendingPathComponent(DirectoryNames.clipped_files)
        finishedDirectory = documentsDirectory.appendingPathComponent(DirectoryNames.finished_files)
        
        createDirectory(rawDirectory.path)
        createDirectory(clipsDirectory.path)
        createDirectory(finishedDirectory.path)
        
        //delete all raw recordings (temp files)
        self.deleteAllRecordings(rawDirectory)
        
    }
    
    func startRecording() {
        
        let url = rawDirectory.appendingPathComponent("\(getFileCount(rawDirectory.path)).m4a")
        
        do {
            try audioRecorder = AVAudioRecorder(url: url, settings: recordingSettings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            //meterTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateMeters), userInfo: nil, repeats: true)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func copy(file fromPath: URL, to newPath: URL, isDirectory: Bool, completion: (_ newURL: URL) -> Void) {
        
        var destinationPath = newPath
        
        var i = 1
        
        while fileManager.fileExists(atPath: destinationPath.path) {
            let basePath = destinationPath.deletingLastPathComponent()
            let name = destinationPath.lastPathComponent
            if isDirectory {
                destinationPath = basePath.appendingPathComponent("\(name) \(i)")
            } else {
                destinationPath = basePath.appendingPathExtension("\(name) \(i).m4a")
            }
            i += 1
        }
        
        do {
            try fileManager.copyItem(at: fromPath, to: destinationPath)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let oldKey = fromPath.deletingPathExtension().lastPathComponent
        let newKey = destinationPath.deletingPathExtension().lastPathComponent
        
        if let text = UserDefaults.standard.value(forKey: oldKey) as? String {
            
            UserDefaults.standard.setValue(text, forKey: newKey)
            UserDefaults.standard.synchronize()
            
        }
        
        completion(destinationPath)
        
    }
    
    func rename(file fromPath: URL, to newPath: URL, isDirectory: Bool, completion: (_ newURL: URL) -> Void) {
        
        var destinationPath = newPath
        
        var i = 1
        
        while fileManager.fileExists(atPath: newPath.path) {
            let basePath = destinationPath.deletingPathExtension()
            if isDirectory {
                destinationPath = basePath.appendingPathExtension("\(i)")
            } else {
                destinationPath = basePath.appendingPathExtension("\(i).m4a")
            }
            i += 1
        }
        
        do {
            try fileManager.moveItem(at: fromPath, to: newPath)
        } catch {
            print(error.localizedDescription)
        }
        
        let oldKey = fromPath.deletingPathExtension().lastPathComponent
        let newKey = destinationPath.deletingPathExtension().lastPathComponent
        
        if let text = UserDefaults.standard.value(forKey: oldKey) as? String {
            
            UserDefaults.standard.setValue(text, forKey: newKey)
            UserDefaults.standard.synchronize()
            
        }
        
        completion(destinationPath)
        
    }
    
    func delete(recording: RawRecording) {
        
        if let url = recording.url {
            
            print("Removing recording at path: \(url.path)")
            
            do {
                try fileManager.removeItem(at: URL(fileURLWithPath: url.path))
                FirebaseAnalyticsManager.shared.recordingDeleted(recordingName: recording.name ?? "No Name")
            } catch let error {
                print("Failed")
                print(error.localizedDescription)
            }
            
        } else {
            print("Invalid url")
        }
        
    }
    
    func finishRecording(_ outputURL: URL, _ prettyFilename: String, completion: @escaping (_ success: Bool) -> Void) {
        
        if audioRecorder != nil && audioRecorder.isRecording {
            
            audioRecorder.stop()
            
            let url = audioRecorder.url
            let asset = AVAsset(url: url)
            
            let clipsFile = self.clipsDirectory.appendingPathComponent(prettyFilename, isDirectory: true)
            createDirectory(clipsFile.path)
            AssetExporter.shared.exportAsset(asset, clipsFile, outputURL, clips) {
                success in
                
                if success {
                    
                    self.audioRecorder = nil
                    UserDefaults.standard.set(true, forKey: "\(outputURL.deletingPathExtension().lastPathComponent)isnew")
                    UserDefaults.standard.synchronize()
                    
                }
                
                completion(success)
                
            }
            
            
        }
        
    }
    
    func cancelRecording() {
        
        /*if meterTimer != nil {
            meterTimer.invalidate()
            meterTimer = nil
        }*/
        
        if audioRecorder != nil && audioRecorder.isRecording {
            
            audioRecorder.stop()
            audioRecorder.deleteRecording()
            
        }
        
    }
    
    func saveClip(length: Double) {
        let endMarker = Date().timeIntervalSince(startDate)
        var startMarker = endMarker - length
        if startMarker < 0 { startMarker = 0 }
        if clips.count > 0 && startMarker < clips.last!.end { startMarker = clips.last!.end }
        print("Start marker \(startMarker)")
        print("End marker \(endMarker)")
        let clip = Clip(start: startMarker, end: endMarker)
        clips.append(clip)
    }
    
    
    ///////////
    ///////////
    ///////////
    ///////////
    ///////////
    
    
    
    fileprivate func createDirectory(_ filepath: String) {
        
        if fileManager.fileExists(atPath: filepath) {
            return
        }
        
        do {
            try fileManager.createDirectory(atPath: filepath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        
    }
    
    func deleteAllRecordings(_ directory: URL, deleteDirectory: Bool = false) {
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directory.path)
            var recordings = files.filter( { (name: String) -> Bool in
                return (name.hasSuffix("m4a"))
            })
            for i in 0 ..< recordings.count {
                
                let path = directory.appendingPathComponent(recordings[i]).path
                
                print("Removing \(path)")
                
                do {
                    try fileManager.removeItem(atPath: path)
                } catch let error as NSError {
                    print("Could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print("Could not get contents of directory at \(directory.path)")
            print(error.localizedDescription)
        }
        
        if deleteDirectory {
            print("Removing directory at path: \(directory.path)")
            do {
                try fileManager.removeItem(at: directory)
            } catch let error {
                print("Failed to remove directory at path: \(directory.path)")
                print(error.localizedDescription)
            }
        }
        
    }
    
    func updateMeters() {
        
        if audioRecorder != nil && audioRecorder.isRecording {
            
            /*if let delegate = self.delegate {
                audioRecorder.updateMeters()
                delegate.updateSoundMeter(value: audioRecorder.averagePower(forChannel: 0))
            }*/
            
        }
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        /*if meterTimer != nil {
            meterTimer.invalidate()
            meterTimer = nil
        }*/
        
    }
    
    func getFileCount(_ directoryPath: String) -> Int {
        
        let dirContents = getFiles(directoryPath)
        let count = dirContents?.count
        return count ?? 0
    }
    
    func getFiles(_ directoryPath: String) -> [String]? {
        let dirContents = try? fileManager.contentsOfDirectory(atPath: directoryPath)
        return dirContents
    }
    
    func setSessionAndRecord() {
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        } catch let error {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
            session.requestRecordPermission() { [weak self]
                granted in
                
                if granted {
                    print("Permission granted")
                    self?.startDate = Date()
                    self?.clips.removeAll()
                    self?.startRecording()
                } else {
                    print("Permission denied")
                }
                
            }
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
        
    }
    
}
