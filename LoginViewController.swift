//
//  LoginViewController.swift
//  DNApp
//
//  Created by Meng To on 2015-01-29.
//  Copyright (c) 2015 Meng To. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    func loginViewControllerDidLogin(controller: LoginViewController)
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var dialogView: DesignableView!
    @IBOutlet weak var emailImageView: SpringImageView!
    @IBOutlet weak var passwordImageView: SpringImageView!
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    weak var delegate: LoginViewControllerDelegate?
    
    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginButtonDidTouch(sender: AnyObject) {
        DNService.loginWithEmail(emailTextField.text, password: passwordTextField.text) { (token) -> () in
            if let token = token {
                LocalStore.saveToken(token)
                self.dismissViewControllerAnimated(true, completion: nil)
                self.delegate?.loginViewControllerDidLogin(self)
            } else {
                self.dialogView.animation = "shake"
                self.dialogView.animate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == emailTextField {
            emailImageView.image = UIImage(named: "icon-mail-active")
            emailImageView.animate()
        } else {
            emailImageView.image = UIImage(named: "icon-mail")
        }
        
        if textField == passwordTextField {
            passwordImageView.image = UIImage(named: "icon-password-active")
            passwordImageView.animate()
        } else {
            passwordImageView.image = UIImage(named: "icon-password")
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        emailImageView.image = UIImage(named: "icon-mail")
        passwordImageView.image = UIImage(named: "icon-password")
    }
    
}










