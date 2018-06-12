//
//  AudioFileMerger.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-11.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import AVFoundation

class AudioFileMerger {
    
    static let shared = AudioFileMerger()
    
    func mergeAudio(_ outputURL: URL, _ clipOutputURL: URL, completion: @escaping (_ success: Bool) -> Void) {
        
        //get all audio files from directory
        
        let clipDirectory = clipOutputURL.deletingLastPathComponent()
        
        let clips = try? FileManager.default.contentsOfDirectory(atPath: clipDirectory.path)
        
        var mergeURLs = [URL]()
        
        if clips != nil {
            
            if clips!.count == 1 {
                
                if let url = clipDirectory.appendingPathComponent(clips!.first!) as URL? {
                    
                    RecordingService.shared.copy(file: url, to: outputURL, isDirectory: false) {
                        _ in
                        
                        completion(true)
                    }
                    
                } else {
                    completion(false)
                }
                
                return
                
            } else if clips!.count > 0 {
                
                for i in 0..<clips!.count {
                    let clip = clips![i]
                    let clipFileURL = clipDirectory.appendingPathComponent(clip)
                    if !FileManager.default.fileExists(atPath: clipFileURL.path) { continue }
                    mergeURLs.append(clipFileURL)
                }
                
                let composition = AVMutableComposition()
                
                for i in 0..<mergeURLs.count {
                    
                    let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())
                    
                    let avAsset = AVURLAsset(url: mergeURLs[i])
                    let track = avAsset.tracks(withMediaType: AVMediaType.audio).first!
                    let timeRange = CMTimeRangeMake(kCMTimeZero, track.timeRange.duration)
                    
                    try? compositionTrack?.insertTimeRange(timeRange, of: track, at: composition.duration)
                    
                }
                
                let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
                assetExport?.outputFileType = AVFileType.m4a
                assetExport?.outputURL = outputURL
                
                if assetExport != nil {
                    
                    if FileManager.default.fileExists(atPath: assetExport!.outputURL!.path) {
                        
                        try? FileManager.default.removeItem(at: assetExport!.outputURL!)
                        
                    }
                    
                }
                
                assetExport?.exportAsynchronously {
                    switch assetExport!.status {
                    case .failed:
                        print("Merge export failed")
                        print(assetExport?.error!.localizedDescription ?? "Error unknown")
                        completion(false)
                        break
                    case .cancelled:
                        print("Merge export cancelled")
                        print(assetExport?.error!.localizedDescription ?? "Error unknown")
                        completion(false)
                        break
                    default:
                        print("Merge successfully exported!")
                        /*
                         FirebaseAnalyticsManager.shared.soundbiteSaved(duration: assetExport!.asset.duration.seconds, numberOfBits: mergeURLs.count, soundbiteName: assetExport!.outputURL!.deletingPathExtension().lastPathComponent)
                         */
                        completion(true)
                        break
                    }
                }
                
            } else {
                completion(false)
            }
            
        } else {
            completion(false)
        }
        
    }
    
}
