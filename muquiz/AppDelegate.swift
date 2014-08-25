//
//  AppDelegate.swift
//  muquiz
//
//  Created by Hannah Reuterdahl on 2014-06-23.
//  Copyright (c) 2014 game. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore
import GPUImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var mask: CALayer?
    var imageView: UIImageView?
    var masterViewController: UINavigationController!
    var spotifyController : SpotifyController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let imageView = UIImageView(frame: self.window!.frame)
        imageView.image = UIImage(named: "bg_image_1.jpg")
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
       /*
        let introLabel = UILabel(frame: CGRectMake(150.0, 150.0, 100.0, 40.0))
        introLabel.text = "Muquiz"
        introLabel.textColor = UIColor.whiteColor()
        self.window!.addSubview(introLabel)
        
        */
        //var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        //var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        //effectView.frame = imageView.bounds
        //imageView.addSubview(effectView)
        
        self.window!.addSubview(imageView)
        /*
        self.mask = CALayer()
        self.mask!.contents = UIImage(named: "round_mask.png").CGImage
        self.mask!.contentsGravity = kCAGravityResizeAspectFill
        self.mask!.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.mask!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.mask!.position = CGPoint(x: imageView.frame.size.width/2, y: imageView.frame.size.height/2)
        
        imageView.layer.mask = mask
        self.imageView = imageView*/
        
        var filter : GPUImagePixellateFilter = GPUImagePixellateFilter()
        
        imageView.image = filter.imageByFilteringImage(imageView.image)

       // imageView.image.applyExtraLightEffect()
          
        //animateMask()
        
        // Override point for customization after application launch.
        //self.window!.backgroundColor = UIColor(red: 255/255, green: 117/255, blue: 89/255, alpha: 1)
        //self.window!.makeKeyAndVisible()
        UIApplication.sharedApplication().statusBarHidden = true
        
        self.window!.rootViewController = UINavigationController()
        var rootViewController = self.window!.rootViewController as UINavigationController
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let LoginController :LoginViewController = LoginViewController()
        var profileViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as LoginViewController
        profileViewController.spotifyController = self.spotifyController
        profileViewController.setSpotifyController()
        rootViewController.pushViewController(profileViewController, animated: true)
        
        return true
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func animateMask() {
        
        self.mask!.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 1
        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = NSValue(CGRect: mask!.bounds)
        let secondBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 90, height: 90))
        let finalBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 1500, height: 1500))
        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.3, 1]
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        self.mask!.addAnimation(keyFrameAnimation, forKey: "bounds")
       
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
         self.mask!.bounds = CGRect(x: 0, y: 0, width: 1500, height: 1500)
        self.window!.rootViewController = UINavigationController()
        var rootViewController = self.window!.rootViewController as UINavigationController
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var profileViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as LoginViewController
        rootViewController.pushViewController(profileViewController, animated: true)
        
        
    }
    
    
    func setSpotifyController()->SpotifyController
    {
        if(spotifyController == nil)
        {
            spotifyController = SpotifyController();
        }
        return spotifyController!;
    }
    
    


}

