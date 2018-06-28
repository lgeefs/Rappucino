//
//  FirstViewController.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-05-31.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class FirstViewController: UIViewController, MeterDelegate {
    
    var webView: WKWebView!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    var default_query: String = {
        return UserDefaults.standard.string(forKey: "default_query") ?? ""
    }()
    
    let alertController = UIAlertController(title: "Save", message: "Title of clip", preferredStyle: .alert)
    
    
    var tapLength: Int! {
        get {
            return UserDefaults.standard.value(forKey: "tapTextFieldValue") as? Int ?? 10
        }
    }
    
    var doubleTapLength: Int! {
        get {
            return UserDefaults.standard.value(forKey: "doubleTapTextFieldValue") as? Int ?? 20
        }
    }
    
    func updateSoundMeter(value: Float) {
        //handle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupUI()
        loadWebview()
        setupAlertController() //only call this once! will crash if initialized twice
        setupRecordingSession()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        layoutUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        let webKitConfig = WKWebViewConfiguration()
        webKitConfig.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: CGRect(x: 0, y: navigationController?.navigationBar.frame.height ?? 20, width: view.bounds.width, height: view.bounds.height*0.6), configuration: webKitConfig)
        
        self.view.addSubview(webView)
        
        recordButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        
        recordButton.addTarget(self, action: #selector(recordButtonTouched(sender:)), for: .touchDown)
        recordButton.addTarget(self, action: #selector(recordButtonUntouched(sender:)), for: [.touchUpInside, .touchUpOutside])
        
        finishButton.addTarget(self, action: #selector(finishButtonPressed(sender:)), for: .touchUpInside)
        
        //self.view.bringSubview(toFront: recordButton)
        //self.view.bringSubview(toFront: finishButton)
        
    }
    
    func loadWebview() {
        
        let myURL = URL(string: "https://www.youtube.com" + default_query)
        let youtubeRequest = URLRequest(url: myURL!)
        webView.load(youtubeRequest)
        
    }
    
    func layoutUI() {
        
        // simple vars
        let w = view.bounds.width
        let h = view.bounds.height
        
        // button diameter
        let bd = w*0.4
        
        recordButton.frame = CGRect(x: w*0.1, y: h*0.66, width: bd, height: bd)
        recordButton.layer.cornerRadius = recordButton.frame.width*0.5
        
        finishButton.frame = CGRect(x: w*0.9-bd*0.75, y: h*0.66 + bd*0.125, width: bd*0.75, height: bd*0.75)
        finishButton.layer.cornerRadius = finishButton.frame.width*0.5
        
    }

    //*************************************************************
    //MARK: - RecordButtonGestureRecognizers
    //*************************************************************
    
    var touchDownTime: Date!
    var touchUpTime: Date!
    
    let minHoldDuration = 1.0
    let maxDoubleTapDuration = 0.5
    var singleTap = false
    
    //****************************
    
    //record button pressed
    
    @objc func recordButtonTouched(sender: UIButton) {
        
        touchDownTime = Date()
        
    }
    
    //record button released
    
    @objc func recordButtonUntouched(sender: UIButton) {
        
        touchUpTime = Date()
        
        processTaps()
        
    }
    
    // determine whether button was single tapped, double tapped, or held down
    
    func processTaps() {
        
        let holdTime = touchUpTime.timeIntervalSince(touchDownTime)
        
        if holdTime >= minHoldDuration {
            RecordingService.shared.saveClip(length: holdTime)
        } else {
            if singleTap {
                singleTap = false
                return
            }
            singleTap = true
            self.perform(#selector(recordTap), with: self, afterDelay: maxDoubleTapDuration)
        }
        
    }
    
    @objc func recordTap() {
        
        if !singleTap {
            
            RecordingService.shared.saveClip(length: Double(doubleTapLength))
            
        } else {
            
            RecordingService.shared.saveClip(length: Double(tapLength))
            singleTap = false
            
        }
        
    }
    
    /************************/
    //MARK: - AlertController
    /************************/
    
    func setupAlertController() {
        
        //cancel pressed
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //save pressed
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self]
            alert in
            
            //show start screen again
            
            //self?.displayStartScreen()
            
            //file number iterator
            
            var i = 1
            
            if let textField = self?.alertController.textFields?.first {
                
                var filename = (textField.text?.count)! > 0 ? "\(textField.text!)" : "My Rap"
                
                var outputFilepath = RecordingService.shared.finishedDirectory.appendingPathComponent(filename).appendingPathExtension("m4a")
                
                while FileManager.default.fileExists(atPath: outputFilepath.path) {
                    
                    // if filename is already taken, add suffix (1) to it. if that is taken, then
                    
                    filename = i > 1 ? filename.replacingOccurrences(of: "\(i-1)", with: "\(i)") : "\(filename) \(i)"
                    
                    outputFilepath = RecordingService.shared.finishedDirectory.appendingPathComponent(filename).appendingPathExtension("m4a")
                    i += 1
                    
                }
                
                // clear textfield text
                
                textField.text = ""
                
                RecordingService.shared.finishRecording(outputFilepath, filename) {
                    success in
                    
                    print(outputFilepath.absoluteString)
                    
                    if success {
                        
                        DispatchQueue.main.async {
                            //self?.displayMenuNotification()
                        }
                        
                    }
                    
                }
                                
            }
            
        }
        
        alertController.addTextField {
            textField in
            
            textField.placeholder = "My Rap"
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
    }
    
    /******************
    * RecordingSession
    ******************/
    
    func setupRecordingSession() {
        
        RecordingService.shared.setSessionAndRecord()
        RecordingService.shared.delegate = self
        
    }
    
    @objc func finishButtonPressed(sender: UIButton) {
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func cancelButtonPressed(sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to delete your soundbite?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            alert in
            
            RecordingService.shared.cancelRecording()
            
            //self.finishButton.alpha = 0
            //self.cancelButton.alpha = 0
            
            //self.displayStartScreen()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

}

