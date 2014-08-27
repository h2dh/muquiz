//
//  customSegue.swift
//  muquiz
//
//  Created by Hannah Reuterdahl on 18/08/14.
//  Copyright (c) 2014 game. All rights reserved.
//

import UIKit
import QuartzCore
import Foundation
import MediaPlayer

@objc(InsetBlurModalSeque) class InsetBlurModalSeque: UIStoryboardSegue {
    
    override func perform() {
        let sourceViewController = self.sourceViewController as UIViewController
        let destinationViewController = self.destinationViewController as UIViewController
        
        // Make sure the background is ransparent
        destinationViewController.view.backgroundColor = UIColor.clearColor()
        
        // Take screenshot from source VC
        UIGraphicsBeginImageContext(sourceViewController.view.bounds.size)
        sourceViewController.view.drawViewHierarchyInRect(sourceViewController.view.frame, afterScreenUpdates:true)
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Blur screenshot
        var blurredImage:UIImage = image//image.applyBlurWithRadius(5, tintColor: UIColor(white: 1.0, alpha: 0.0), saturationDeltaFactor: 1.3, maskImage: nil)
        
        // Crop screenshot, add to view and send to back
        let blurredBackgroundImageView : UIImageView = UIImageView(image:blurredImage)
        blurredBackgroundImageView.clipsToBounds = true;
        blurredBackgroundImageView.contentMode = UIViewContentMode.Center
        let insets:UIEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        blurredBackgroundImageView.frame = UIEdgeInsetsInsetRect(blurredBackgroundImageView.frame, insets)
        
        destinationViewController.view.addSubview(blurredBackgroundImageView)
        destinationViewController.view.sendSubviewToBack(blurredBackgroundImageView)
        
        // Add original screenshot behind blurred image
        let backgroundImageView : UIImageView = UIImageView(image:image)
        destinationViewController.view.addSubview(backgroundImageView)
        destinationViewController.view.sendSubviewToBack(backgroundImageView)
        
        // Add the destination view as a subview, temporarily – we need this do to the animation
        sourceViewController.view.addSubview(destinationViewController.view)
        
        // Set initial state of animation
        destinationViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        blurredBackgroundImageView.alpha = 0.0;
        backgroundImageView.alpha = 0.0;
        
        // Animate
        UIView.animateWithDuration(1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 30.0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                destinationViewController.view.transform = CGAffineTransformIdentity
                blurredBackgroundImageView.alpha = 1.0
                backgroundImageView.alpha = 1.0;
                
            },
            completion: { (fininshed: Bool) -> () in
                // Remove from temp super view
                destinationViewController.view.removeFromSuperview()
                
                sourceViewController.presentViewController(destinationViewController, animated: false, completion: nil)
            }
        )
        
    }
    
}