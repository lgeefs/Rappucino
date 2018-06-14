//
//  RecordingTableViewCell.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-12.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

//
//  RecordingTableHeader.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-21.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class RecordingTableViewCell: UITableViewCell, PlayerServiceDelegate, UITextFieldDelegate {
    
    var nameTextField: UITextField!
    var playButton: UIButton!
    var dateLabel: UILabel!
    var durationLabel: UILabel!
    var shareButton: UIButton!
    
    var deleteButton: UIButton!
    
    var timeTicker: UIView!
    var timer: Timer!
    
    var index: Int! {
        didSet {
            //print("Old index: \(oldValue)\n New index: \(index)")
        }
    }
    
    let playImage = #imageLiteral(resourceName: "play")
    let pauseImage = #imageLiteral(resourceName: "pause")
    
    var recording: FinishedRecording! {
        didSet {
            update()
            //print(recording.name)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print(recording.name)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutUI()
        
    }
    
    func setupUI() {
        
        //self.contentView.backgroundColor = .white
        
        nameTextField = UITextField()
        //nameTextField.textColor = customLightGray
        //nameTextField.font = UIFont(name: fontName, size: Fonts.large)
        nameTextField.adjustsFontSizeToFitWidth = true
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        self.contentView.addSubview(nameTextField)
        
        playButton = UIButton()
        playButton.setImage(playImage, for: .normal)
        playButton.contentMode = .scaleAspectFit
        playButton.addTarget(self, action: #selector(playButtonPressed(sender:)), for: .touchUpInside)
        //self.contentView.addSubview(playButton)
        
        dateLabel = UILabel()
        //dateLabel.textColor = customLightGray
        dateLabel.contentMode = .top
        //dateLabel.font = UIFont(name: fontName, size: Fonts.smaller)
        dateLabel.adjustsFontSizeToFitWidth = true
        //self.contentView.addSubview(dateLabel)
        
        durationLabel = UILabel()
        durationLabel.textColor = .white
        durationLabel.contentMode = .top
        durationLabel.textAlignment = .right
        //durationLabel.font = UIFont(name: fontName, size: Fonts.small)
        durationLabel.adjustsFontSizeToFitWidth = true
        //self.contentView.addSubview(durationLabel)
        
        shareButton = UIButton()
        shareButton.setTitle("Share", for: .normal) //shareButton.setImage(UIImage(), for: .normal)
        //shareButton.contentMode = .scaleAspectFit
        shareButton.addTarget(self, action: #selector(shareButtonPressed(sender:)), for: .touchUpInside)
        //self.contentView.addSubview(shareButton)
        
        deleteButton = UIButton()
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        //deleteButton.titleLabel?.font = UIFont(name: fontName, size: Fonts.medium)
        deleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
        deleteButton.backgroundColor = .red
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed(sender:)), for: .touchUpInside)
        //self.backgroundView = UIView(frame: contentView.frame)
        //self.backgroundView?.addSubview(deleteButton)
        
        timeTicker = UIView()
        timeTicker.backgroundColor = .white
        //self.contentView.addSubview(timeTicker)
        
    }
    
    func layoutUI() {
        
        //var multiplier: CGFloat = 1.0
        shareButton.alpha = 0
        
        let width = self.contentView.bounds.width//*multiplier
        let height = self.contentView.bounds.height
        let leftMargin = width*0.1
        let topMargin = height*0.05
        
        nameTextField.frame = CGRect(x: leftMargin, y: topMargin, width: width*0.7, height: height*0.5)
        
        playButton.frame = CGRect(x: self.contentView.bounds.width*0.06, y: self.contentView.bounds.height*0.5-self.contentView.frame.size.height*0.25, width: self.contentView.bounds.width*0.06, height: self.self.contentView.frame.size.height*0.5)
        
        dateLabel.frame = CGRect(x: leftMargin, y: self.contentView.frame.maxY-((self.contentView.bounds.height-self.contentView.frame.size.height)*0.1), width: width*0.65, height: height*0.1)
        
        durationLabel.frame = CGRect(x: self.contentView.bounds.width*0.5, y: 0, width: self.contentView.bounds.width*0.3, height: self.contentView.bounds.height)
        
        shareButton.frame = CGRect(x: self.contentView.frame.maxX, y: 0, width: self.bounds.width-self.contentView.frame.maxX, height: height)
        
        //deleteButton.frame = CGRect(x: self.backgroundView!.bounds.width*0.75, y: 0, width: self.backgroundView!.bounds.width*0.25, height: self.backgroundView!.bounds.height)
        
        timeTicker.frame = CGRect(x: 0, y: 0, width: 1, height: self.contentView.frame.size.height)
        
    }
    
    @objc func shareButtonPressed(sender: UIButton) {
        
        //let vc = UIActivityViewController(activityItems: [recording.url], applicationActivities: [])
        
    }
    
    func recordingInterrupted() {
        playButton.setImage(playImage, for: .normal)
    }
    
    @objc func playButtonPressed(sender: Any) {
        
        if !recording.isPlaying {
            PlayerService.shared.play(recording: self.recording)
            PlayerService.shared.delegate = self
            playButton.setImage(pauseImage, for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(moveTimeTick(timer:)), userInfo: nil, repeats: true)
        } else {
            PlayerService.shared.pause()
            playButton.setImage(playImage, for: .normal)
            timer.invalidate()
        }
        
    }
    
    func finishedPlaying() {
        timer.invalidate()
        timer = nil
        playButton.setImage(playImage, for: .normal)
    }
    
    @objc func moveTimeTick(timer: Timer) {
        
        if recording.duration > 0 {
            
            timeTicker.center.x = CGFloat(recording.currentTime)/CGFloat(recording.duration)*CGFloat(self.self.contentView.bounds.width*0.825)
            
        }
        
    }
    
    func showDeleteButton(gesture: UISwipeGestureRecognizer?) {
        
        UIView.animate(withDuration: 0.25) {
            self.contentView.center.x = self.center.x - self.deleteButton.bounds.width
        }
        
    }
    
    func hideDeleteButton(gesture: Any?) {
        
        UIView.animate(withDuration: 0.25) {
            self.contentView.center.x = self.center.x
        }
        
    }
    
    @objc func deleteButtonPressed(sender: UIButton) {
        PlayerService.shared.pause()
        hideDeleteButton(gesture: sender)
        RecordingService.shared.delete(recording: self.recording)
        UserDefaults.standard.setValue(nil, forKey: self.recording.name)
        UserDefaults.standard.setValue(nil, forKey: "\(self.recording.name)isnew")
        UserDefaults.standard.synchronize()
    RecordingService.shared.deleteAllRecordings(RecordingService.shared.clipsDirectory.appendingPathComponent(self.recording.name, isDirectory: true), deleteDirectory: true)
        
        FirebaseAnalyticsManager.shared.soundbiteDeleted()
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != self.recording.name {
            
            let newname = textField.text!
            let clipDirectory = RecordingService.shared.clipsDirectory.appendingPathComponent(self.recording.name, isDirectory: true)
            let newDirectoryPath = clipDirectory.deletingLastPathComponent().appendingPathComponent(newname)
            RecordingService.shared.rename(file: clipDirectory, to: newDirectoryPath, isDirectory: true) { newURL in
                self.recording.name = newURL.lastPathComponent
                textField.text = self.recording.name
            }
            let newFilePath = self.recording.url.deletingLastPathComponent().appendingPathComponent(newname).appendingPathExtension(".m4a")
            RecordingService.shared.rename(file: self.recording.url, to: newFilePath, isDirectory: false) {
                newURL in
                self.recording.url = newURL
                DispatchQueue.main.async {
                    (self.superview as! UITableView).reloadData()
                }
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    
    func update() {
        
        nameTextField.text = recording.name
        dateLabel.text = convertToDateString(recording.creationDate)
        durationLabel.text = convertToTimeString(recording.duration)
        if recording.isPlaying {
            playButton.setImage(pauseImage, for: .normal)
        } else {
            playButton.setImage(playImage, for: .normal)
        }
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(moveTimeTick(timer:)), userInfo: nil, repeats: true)
        
    }
    
    fileprivate func convertToDateString(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
        
    }
    
    
    fileprivate func convertToTimeString(_ duration: Double) -> String {
        
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        
        var zeroPad1 = ""
        var zeroPad2 = ""
        
        if minutes < 10 {
            zeroPad1 = "0"
        }
        if seconds < 10 {
            zeroPad2 = "0"
        }
        
        return "\(zeroPad1)\(minutes):\(zeroPad2)\(seconds)"
        
    }
    
    /*override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view! is UIButton {
            return false
        } else {
            return true
        }
    }*/
    
}
