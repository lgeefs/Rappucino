//
//  LoginViewController.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-22.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var loginLabel: UILabel!
    var nameTextField: UITextField!
    var handleTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var noAccountButton: UIButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        layoutUI()
        
    }
    
    func setupUI() {
        
        self.view.backgroundColor = .white
        
        loginLabel = UILabel()
        loginLabel.text = "Who's rapping?"
        loginLabel.font = UIFont.systemFont(ofSize: 24)
        self.view.addSubview(loginLabel)
        
        nameTextField = UITextField()
        nameTextField.placeholder = "Your name"
        nameTextField.font = UIFont.systemFont(ofSize: 18)
        nameTextField.isHidden = true
        nameTextField.autocapitalizationType = .words
        self.view.addSubview(nameTextField)
        
        handleTextField = UITextField()
        handleTextField.placeholder = "Rapper handle"
        handleTextField.font = UIFont.systemFont(ofSize: 18)
        handleTextField.delegate = self
        handleTextField.autocapitalizationType = .none
        self.view.addSubview(handleTextField)
        
        passwordTextField = UITextField()
        passwordTextField.placeholder = "Password"
        passwordTextField.font = UIFont.systemFont(ofSize: 18)
        passwordTextField.isSecureTextEntry = true
        self.view.addSubview(passwordTextField)
        
        loginButton = UIButton()
        loginButton.setTitle("Let's goooo", for: .normal)
        loginButton.backgroundColor = UIColor.blue
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        loginButton.addTarget(self, action: #selector(loginButtonPressed(sender:)), for: .touchDown)
        self.view.addSubview(loginButton)
        
        noAccountButton = UIButton()
        noAccountButton.setTitle("I don't have an account", for: .normal)
        noAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        noAccountButton.setTitleColor(.blue, for: .normal)
        noAccountButton.addTarget(self, action: #selector(noAccountButtonPressed(sender:)), for: .touchDown)
        self.view.addSubview(noAccountButton)
        
    }
    
    func layoutUI() {
        
        let w = view.bounds.width
        let h = view.bounds.height
        let lm = w*0.25
        let vw = w*0.5
        let vh = h*0.1
        
        loginLabel.frame = CGRect(x: lm, y: 20, width: vw, height: vh)
        
        let nameTextField_y = nameTextField.isHidden ? 20 : loginLabel.frame.maxY
        
        nameTextField.frame = CGRect(x: lm, y: nameTextField_y, width: vw, height: vh)
        
        handleTextField.frame = CGRect(x: lm, y: nameTextField.frame.maxY, width: vw, height: vh)
        
        passwordTextField.frame = CGRect(x: lm, y: handleTextField.frame.maxY, width: vw, height: vh)
        
        noAccountButton.frame = CGRect(x: lm, y: view.frame.maxY-vh, width: vw, height: vh*0.75)
        
        loginButton.frame = CGRect(x: lm, y: noAccountButton.frame.minY - vh*0.75, width: vw, height: vh*0.75)
        
    }
    
    @objc func loginButtonPressed(sender: UIButton) {
        
        if nameTextField.text!.count > 0 {
            //register
        } else {
            //login
        }
        
        print(nameTextField.text!)
        print(handleTextField.text!)
        print(passwordTextField.text!)
        
    }
    
    @objc func noAccountButtonPressed(sender: UIButton) {
        
        nameTextField.isHidden = false
        noAccountButton.isHidden = true
        layoutUI()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.replacingOccurrences(of: " ", with: "_")
    }
    
}
