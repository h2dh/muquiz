//
//  ViewController.swift
//  muquiz
//
//  Created by Hannah Reuterdahl on 2014-06-23.
//  Copyright (c) 2014 game. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var usernameTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var loginButton : UIButton!
    @IBOutlet var backgroundImageView : UIImageView!
    
    @IBOutlet weak var vinyl1: UIImageView!
    var spotifyController : SpotifyController!
    var successfullLogin : Bool = false
    var keypath : String = ""
    
    override func viewWillAppear(animated: Bool) {
        self.addObserver(self, forKeyPath: "spotifyController.loggedInUser", options: .New, context: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.passwordTextField.delegate = self
        self.usernameTextField.delegate = self
        
        self.view.bringSubviewToFront(self.passwordTextField)
        self.view.bringSubviewToFront(self.usernameTextField)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.usernameTextField) {
            textField.resignFirstResponder();
            self.passwordTextField.becomeFirstResponder()
            return false;
        } else if (textField == self.passwordTextField) {
            textField.resignFirstResponder()
            return true
        }
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {

        SPDispatchAsync({
            self.spotifyController.loginWithUserName(self.usernameTextField.text, andPassword:self.passwordTextField.text)
            dispatch_async(dispatch_get_main_queue(), {
                self.successfullLogin = true
                self.usernameTextField.text = self.spotifyController.loggedInUser
            })
        })
        
    }

    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        
        if keyPath == "spotifyController.loggedInUser" {
            if self.spotifyController.loggedInUser != nil {
                self.keypath = "spotifyController.loggedInUser"
                self.usernameTextField.text = self.spotifyController.loggedInUser
                self.successfullLogin = true
                self.shouldPerformSegueWithIdentifier("push", sender: self)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if (self.successfullLogin) {
                     
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var mainVC = mainStoryboard.instantiateViewControllerWithIdentifier("PlayBoardViewController") as PlayBoardViewController
            
            mainVC.spotifyController = self.spotifyController
            self.presentViewController(mainVC, animated:false, completion: nil)
            self.successfullLogin = false;
            self.removeObserver(self, forKeyPath: "spotifyController.loggedInUser")
   
            return true
        }
        return false
    }

}
