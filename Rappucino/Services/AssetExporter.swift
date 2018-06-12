//
//  ExportController.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-14.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import AVFoundation

class AssetExporter {
    
    static let shared = AssetExporter()
    
    private init() {}
    
    func exportAsset(_ asset: AVAsset, _ directory: URL, _ outputFile: URL, _ clips: [Clip], completion: @escaping (_ success: Bool) -> Void) {
        
        let fileManager = FileManager.default
        
        var exporters = [AVAssetExportSession]()
        
        for i in 0..<clips.count {
            let clip = clips[i]
            if clip.end - clip.start < 1 { continue }
            let clipName = "\(i).m4a"
            let clipUrl = directory.appendingPathComponent(clipName)
            if fileManager.fileExists(atPath: clipUrl.path) {
                print("File exists")
            }
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
            exporter?.outputFileType = AVFileType.m4a
            exporter?.outputURL = clipUrl
            print("start=\(clip.start), end=\(clip.end)")
            let startTime = CMTimeMake(Int64(clip.start*100), 100)
            let stopTime = CMTimeMake(Int64(clip.end*100), 100)
            let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            exporter?.timeRange = exportTimeRange
            if exporter != nil {
                exporters.append(exporter!)
            }
        }
        
        let filesToExport = exporters.count
        var exportedFiles = 0
        
        for i in 0..<exporters.count {
            let exporter = exporters[i]
            exporter.exportAsynchronously() {
                switch exporter.status {
                case .failed:
                    print("Export failed")
                    print(exporter.error?.localizedDescription ?? "Unknown Error")
                    break
                case .cancelled:
                    print("Export cancelled")
                    break
                default:
                    print("Export Successfully Finished")
                    
                    break
                }
                
                exportedFiles += 1
                if exportedFiles == filesToExport {
                    AudioFileMerger.shared.mergeAudio(outputFile, exporter.outputURL!) {
                        success in
                        
                        completion(success)
                        
                    }
                }
                
            }
        }
        
    }
    
}
