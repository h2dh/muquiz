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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var mask: CALayer?
    var imageView: UIImageView?
    var masterViewController: UINavigationController!
    var spotifyController : SpotifyController = SpotifyController()
    var succesfulLogin : Bool = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        
        // start of your application:didFinishLaunchingWithOptions // ...
        TestFlight.takeOff("c4af4fd1-4c83-4dc6-b963-dff1f2c8993e")
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        UIApplication.sharedApplication().statusBarHidden = true
        self.window!.rootViewController = UINavigationController()
        var rootViewController = self.window!.rootViewController as UINavigationController
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        rootViewController.navigationBarHidden = true
        
        // Login if we already have saved credentials for user
        self.spotifyController.tryLoginIfStoredCredentials()
        if ((self.spotifyController.loggedInUser) != nil) {
            let mainVC : PlayBoardViewController = mainStoryboard.instantiateViewControllerWithIdentifier("PlayBoardViewController") as PlayBoardViewController
            mainVC.spotifyController = self.spotifyController
                rootViewController.pushViewController(mainVC, animated: true)
        } else {
            let loginVC : LoginViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as LoginViewController
            loginVC.spotifyController = self.spotifyController
            rootViewController.pushViewController(loginVC, animated: true)
        }
    
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
    
    func setSpotifyController()->SpotifyController
    {
        return self.spotifyController;
    }
}

