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
import GPUImage

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundImageCopy: UIImageView!
    @IBOutlet var usernameTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var loginButton : UIButton!
    @IBOutlet var usernameHintLabel : UILabel!
    @IBOutlet var passwordHintLabel : UILabel!
    @IBOutlet var backgroundImageView : UIImageView!
    
    var spotifyController : SpotifyController = SpotifyController()
    var successfullLogin : Bool = false
    var keypath : String = ""
    
    override func viewWillAppear(animated: Bool) {
        self.addObserver(self, forKeyPath: "spotifyController.loggedInUser", options: .New, context: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController.navigationBar.hidden = true
        
        self.usernameTextField.addTarget(self, action: Selector("textFieldShouldEndEditing:"), forControlEvents: UIControlEvents.EditingChanged)
        self.passwordTextField.addTarget(self, action: Selector("textFieldShouldEndEditing:"), forControlEvents: UIControlEvents.EditingChanged)
        
        self.usernameHintLabel.alpha = 0.0
        self.passwordHintLabel.alpha = 0.0
        
        var filter : GPUImagePixellateFilter = GPUImagePixellateFilter()
        var filteredImage : UIImage = filter.imageByFilteringImage(self.backgroundImageView.image)
        self.backgroundImageCopy.image = filteredImage
        
        let transitionFadeOut = CABasicAnimation(keyPath: "opacity")
        
        transitionFadeOut.beginTime = CACurrentMediaTime()
        transitionFadeOut.duration = 0.5
        transitionFadeOut.fromValue = 1.0
        transitionFadeOut.toValue = 0.0
        transitionFadeOut.delegate = self
        transitionFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.backgroundImageCopy.layer.addAnimation(transitionFadeOut, forKey: "opacity")
        self.backgroundImageCopy.layer.opacity = 0.0
        
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = self.backgroundImageView.bounds
        self.backgroundImageView.addSubview(visualEffectView)

        var vibrancy = UIVisualEffectView(effect: UIVibrancyEffect() as UIVibrancyEffect)
        
        vibrancy.frame = self.usernameHintLabel.bounds
        self.usernameHintLabel.addSubview(vibrancy)
        
        vibrancy.frame = self.usernameTextField.bounds
        self.usernameTextField.addSubview(vibrancy)
        
        vibrancy.frame = self.passwordTextField.bounds
        self.passwordTextField.addSubview(vibrancy)
    }

    func textFieldShouldEndEditing(textField: UITextField!) -> Bool {
        if textField.tag == 1 {
            UIView.animateWithDuration(1, animations: {
                self.usernameHintLabel.alpha = 1.0
            })
        } else {
            UIView.animateWithDuration(1, animations: {
                self.passwordHintLabel.alpha = 1.0
            })
        }
        return true
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
            })
        })
        
    }

    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        
        if keyPath == "spotifyController.loggedInUser" {
            self.keypath = "spotifyController.loggedInUser"
            self.usernameTextField.text = self.spotifyController.loggedInUser
            self.successfullLogin = true
            self.shouldPerformSegueWithIdentifier("push", sender: self)

        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if (self.successfullLogin) {
                     
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var mainVC = mainStoryboard.instantiateViewControllerWithIdentifier("mainViewController") as mainViewController
            
            mainVC.spotifyController = self.spotifyController
            self.presentViewController(mainVC, animated:false, completion: nil)
   
            return true
        }
        return false
    }
    
    func startBackgroundVideo() {
        
        var playerItem : AVPlayerItem
        var string : String
        var optional : NSURL?
        
        optional = NSBundle.mainBundle().URLForResource("/Users/hannahreuterdahl/Documents/Development/MusiQuiz/backgroundVideo", withExtension: "mp4")
        
        if (optional != nil) {
            var url = optional!
            var player : AVPlayer = AVPlayer.playerWithURL(url) as AVPlayer
            
            var layer : AVPlayerLayer = AVPlayerLayer()
            
            playerItem = AVPlayerItem(URL: url)
            
            player = AVPlayer(playerItem: playerItem)
            var playerLayer : AVPlayerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            playerLayer.frame = self.view!.bounds
            self.view.layer.addSublayer(playerLayer)
        }
        

    }

    override func viewDidDisappear(animated: Bool) {
        self.removeObserver(self, forKeyPath: "spotifyController.loggedInUser")
    }
    
    
    
    func setSpotifyController()->SpotifyController
    {
        if(spotifyController == nil)
        {
            spotifyController = SpotifyController();
        }
        return spotifyController;
    }
}
