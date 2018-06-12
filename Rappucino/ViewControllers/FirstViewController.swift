//
//  FirstViewController.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-05-31.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import UIKit
import WebKit

class FirstViewController: UIViewController, MeterDelegate {
    
    var webView: WKWebView!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
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
        
        RecordingService.shared.setSessionAndRecord()
        RecordingService.shared.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        let webKitConfig = WKWebViewConfiguration()
        webKitConfig.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: CGRect(x: 0, y: navigationController?.navigationBar.frame.height ?? 20, width: view.bounds.width, height: view.bounds.height*0.5), configuration: webKitConfig)
        
        self.view.addSubview(webView)
        
        recordButton.addTarget(self, action: #selector(recordButtonTouched(sender:)), for: .touchDown)
        recordButton.addTarget(self, action: #selector(recordButtonUntouched(sender:)), for: [.touchUpInside, .touchUpOutside])
        
        finishButton.addTarget(self, action: #selector(finishButtonPressed(sender:)), for: .touchUpInside)
        
    }
    
    func loadWebview() {
        
        let myURL = URL(string: "https://www.youtube.com")
        let youtubeRequest = URLRequest(url: myURL!)
        webView.load(youtubeRequest)
        
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
                
                var filename = "\(textField.text!).m4a"
                
                // if textfield is empty, set title to default name
                
                if textField.text! == "" {
                    filename = "My Rap.m4a"
                }
                
                var outputFilepath = RecordingService.shared.finishedDirectory.appendingPathComponent(filename)
                
                while FileManager.default.fileExists(atPath: outputFilepath.path) {
                    
                    // if filename is already taken, add suffix (1) to it. if that is taken, then
                    
                    filename = "\(textField.text!)\(i).m4a"
                    if textField.text! == "" {
                        filename = "\(filename) \(i).m4a"
                    }
                    
                    outputFilepath = RecordingService.shared.finishedDirectory.appendingPathComponent(filename)
                    i += 1
                    
                }
                
                // clear textfield text
                
                textField.text = ""
                
                let endIndex = filename.index(filename.endIndex, offsetBy: -4)
                
                let prettyFilename = String(filename[..<endIndex])
                
                RecordingService.shared.finishRecording(outputFilepath, prettyFilename) {
                    success in
                    
                    print(outputFilepath.absoluteString)
                    
                    if success {
                        
                        DispatchQueue.main.async {
                            //self?.displayMenuNotification()
                        }
                        
                    }
                    
                }
                
                self?.title = "Lets goooo"
                
            }
            
        }
        
        alertController.addTextField {
            textField in
            
            textField.placeholder = "My Rap"
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
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

