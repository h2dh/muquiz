//
//  mainViewController.swift
//  muquiz
//
//  Created by Hannah Reuterdahl on 11/08/14.
//  Copyright (c) 2014 game. All rights reserved.
//

import UIKit
import QuartzCore
import Foundation
import MediaPlayer
import GPUImage

@IBDesignable
class mainViewController: UIViewController {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var background: UIImageView!
    var mask: CALayer?
    var circle : CAShapeLayer = CAShapeLayer()
    var circleFill : CAShapeLayer = CAShapeLayer()
    var currentTrackTitle : NSString = ""
    var currentTrackImage : UIImage?
    var track : Track?
    var spotifyController : SpotifyController!
    var currentGenre : String = ""

    var arrayWithSongs : NSMutableArray = NSMutableArray()
    var userTopList : SPToplist = SPToplist();
    var regionTopList : SPToplist = SPToplist();
    
    @IBOutlet weak var ticker: UILabel!
    var stopWatch : MZTimerLabel = MZTimerLabel()
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var songImageViewCopy: UIImageView!
    @IBOutlet weak var blurryImageView: UIImageView!
    var currentTrack:SPTrack = SPTrack()
    
    var result : NSMutableArray!
    var attributesForChoosenButton : NSDictionary!
    
    var mediaPlayer: MPMoviePlayerController = MPMoviePlayerController()

    @IBOutlet weak var shuffleImageView: UIImageView!
    @IBOutlet var songImageView : UIImageView!
    @IBOutlet var titleLabel : UILabel!

    @IBOutlet var customView : CustomView!
    @IBOutlet var playButton : UIButton!

    
    @IBAction func didPushDoneButton(sender: AnyObject) {
        self.forceEndSong()
    }
    
    func setPlaylistUserTop() {
        self.arrayWithSongs.addObjectsFromArray(self.userTopList.tracks)
    }
    
    func setPlaylistRegionTop() {
        self.arrayWithSongs.addObjectsFromArray(self.regionTopList.tracks)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Then apply the animation.
       
        var animation : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 2.0
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.songImageView.layer.addAnimation(animation, forKey: "opacity")
        
        self.songImageView.layer.opacity = 1.0
        self.shuffleImageView.layer.opacity = 1.0
        shuffleImageView.layer.shadowColor = UIColor.blackColor().CGColor;
        shuffleImageView.layer.shadowOffset = CGSizeMake(0, 1);
        shuffleImageView.layer.shadowOpacity = 1.0;
        shuffleImageView.layer.shadowRadius = 1.0;
        shuffleImageView.clipsToBounds = false;
    
        self.songImageView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        self.shuffleImageView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        
        UIView.animateWithDuration(1.0, delay: 0.3, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            self.songImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            self.shuffleImageView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
        }), completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController.navigationBar.hidden = true
        
        self.songTitleLabel.alpha = 0.0
        
        self.stopWatch = MZTimerLabel(label: self.ticker, andTimerType: MZTimerLabelTypeTimer)
        stopWatch.timeFormat = "SS"
        stopWatch.setCountDownTime(30000)
    
        var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        effectView.frame = self.background.bounds
        self.background.addSubview(effectView)
        
        var filter : GPUImagePixellateFilter = GPUImagePixellateFilter()
        self.songImageView.image = filter.imageByFilteringImage(self.songImageView.image)
        
        self.regionTopList = SPToplist(forLocale: SPSession.sharedSession().locale, inSession: SPSession.sharedSession())
        self.userTopList = SPToplist(forCurrentUserInSession: SPSession.sharedSession())
        
        var loadedUserTop :SPToplist!
        var notLoadedUserTop:SPToplist!
        SPAsyncLoading.waitUntilLoaded(userTopList, timeout: 10.0, then: {(loadedUserTop, notLoadedUserTop) in self.setPlaylistUserTop()})
        
        var loadedRegionTop :SPToplist!
        var notLoadedRegionTop:SPToplist!
        SPAsyncLoading.waitUntilLoaded(userTopList, timeout: 10.0, then: {(loadedRegionTop, notLoadedRegionTop) in self.setPlaylistRegionTop()})
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "songEndedPlaying:", name: "kSPSongEnded", object: nil)
        
        self.addObserver(self, forKeyPath:"spotifyController.search.tracks", options: NSKeyValueObservingOptions.New, context: nil)
        
        self.addObserver(self, forKeyPath: "spotifyController.loggedInUser", options: .New, context: nil)
        
        self.addObserver(self, forKeyPath: "spotifyController.search.playlists", options: .New, context: nil)
        
        // Init first label to start the shuffle
        //attributesForChoosenButton = [NSForegroundColorAttributeName:UIColor.darkGrayColor(), NSStrokeWidthAttributeName:1]
        //self.currentGenre = self.button1.titleLabel.text
        
        //var attributed = NSMutableAttributedString(string: self.button1.titleLabel.text, attributes: attributesForChoosenButton)
       // self.button1.titleLabel.attributedText = attributed
        
        self.titleLabel.alpha = 0.0
        self.shuffleImageView.alpha = 1.0
        self.result = NSMutableArray()
        /*
        for item : AnyObject in self.view.subviews {
            if let button = item as? UIButton {
                button.alpha = 0.0
                button.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
            }
        }*/
        
     
        self.songImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        var radius : CGFloat = songImageView.bounds.size.height/2.0;
        var layer :CAShapeLayer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: songImageView.bounds, cornerRadius: radius).CGPath
        songImageView.layer.mask = layer
        
        var radiusCopy : CGFloat = songImageViewCopy.bounds.size.height/2.0;
        var layerCopy :CAShapeLayer = CAShapeLayer()
        layerCopy.path = UIBezierPath(roundedRect: songImageViewCopy.bounds, cornerRadius: radiusCopy).CGPath
        songImageViewCopy.layer.mask = layerCopy
            
        self.circle.path = UIBezierPath(roundedRect: customView.bounds, cornerRadius: self.songImageView.bounds.size.height/2-15).CGPath
        self.circle.lineWidth = 28.0
        self.circle.strokeColor = UIColor.whiteColor().CGColor
        self.circle.strokeStart = 0.0
        self.circle.strokeEnd = 1.0
        self.circle.fillColor = UIColor.clearColor().CGColor
        
        self.circleFill.path = UIBezierPath(roundedRect: customView.bounds, cornerRadius: self.songImageView.bounds.size.height/2-20).CGPath
        self.circleFill.lineWidth = 15.0
        self.circleFill.strokeColor = UIColor(red: 255.0/255.0, green: 127.0/255.0, blue: 102.0/255.0, alpha: 1.0).CGColor
        self.circleFill.strokeStart = 0.0
        self.circleFill.strokeEnd = 1.0
        self.circleFill.fillColor = UIColor.clearColor().CGColor

        self.songImageView.alpha = 1.0
        
        self.customView.layer.addSublayer(circle)
        self.customView.layer.addSublayer(self.circleFill)

        self.customView.alpha = 0.8
        self.customView.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func didPushPlayButton(sender : AnyObject) {

        self.shuffleImageView.layer.opacity = 1.0
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = NSNumber.numberWithFloat(1.0)
        opacityAnimation.toValue = NSNumber.numberWithFloat(0.0)
        opacityAnimation.duration = 0.3
        
        self.shuffleImageView.layer.addAnimation(opacityAnimation, forKey: "opacity")
        self.shuffleImageView.layer.opacity = 0.0
        
        self.pickRandomSong();
        //self.genrePick(self.currentGenre)
    }
    
    
    func pickRandomSong(){
        if self.arrayWithSongs.count > 0 {
            self.shuffleImageView.alpha = 0.0
            self.titleLabel.alpha = 0.0
            self.songTitleLabel.alpha = 0.0
            var randomNumber = Int(arc4random_uniform(UInt32(self.arrayWithSongs.count)))
            
            var song : SPTrack = self.arrayWithSongs[randomNumber] as SPTrack
            var artist : SPArtist = song.artists[0] as SPArtist
            
            self.currentTrack = song
            
            self.addObserver(self, forKeyPath: "currentTrack.album.cover.image", options: .New, context: nil)
            
            self.titleLabel.text = " by " + song.artists[0].name
            
            self.songTitleLabel.text = song.name
            
            var coverImage : SPImage! = song.album.cover
            var loadedTrack : SPImage!
            var notLoaded : SPImage!
            
            SPAsyncLoading.waitUntilLoaded(coverImage, timeout: 10.0, then: {(
                loadedTrack, notLoaded) in self.setCoverImageAndPlaySong(coverImage.image, song: song)}
            )
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startAnimationForSong() {

        self.playButton.hidden = true
        self.doneButton.hidden = false
        self.playButton.enabled = false
        self.doneButton.enabled = true
        self.circleFill.strokeStart = 0.0
        
        // Change the model layer's property first.
        self.circleFill.strokeEnd = 0.0;
        
        // Then apply the animation.
        var animation : CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 30
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.circleFill.addAnimation(animation, forKey: "strokeEnd")
        
        self.songImageViewCopy.layer.opacity = 1.0
        
        let transitionFadeOut = CABasicAnimation(keyPath: "opacity")
        
        transitionFadeOut.duration = 30
        transitionFadeOut.fromValue = 1.0
        transitionFadeOut.toValue = 0.0
        transitionFadeOut.delegate = self
        transitionFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.songImageViewCopy.layer.addAnimation(transitionFadeOut, forKey: "opacity")
        
        self.songImageViewCopy.layer.opacity = 0.0

    }

    func genrePick(genreName : String){
        var newString = genreName.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)

        self.spotifyController.getTracksForGenre(newString)
    }

    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        
        if keyPath == "spotifyController.search.tracks" {
            self.result.addObjectsFromArray(self.spotifyController.search.tracks)
            self.chooseRandomSongForGenre(self.currentGenre)
        }

        if keyPath == "spotifyController.loggedInUser" {
            self.titleLabel.text = self.spotifyController.loggedInUser
        }
        
        if keyPath == "currentTrack.album.cover.image" {
            self.songImageView.image = self.currentTrack.album.cover.image
        }
        
        if keyPath == "spotifyController.search.playlists"{
            self.pickRandomSong()
        }
    }
    
    func chooseRandomSongForGenre(genre : String) {
        
        if self.result.count > 0 {
            self.shuffleImageView.alpha = 0.0
             self.titleLabel.alpha = 0.0
            var randomNumber = Int(arc4random_uniform(UInt32(self.result.count)))
                
            var song : SPTrack = self.result[randomNumber] as SPTrack
            var artist : SPArtist = song.artists[0] as SPArtist
            
            self.currentTrack = song
            
            self.addObserver(self, forKeyPath: "currentTrack.album.cover.image", options: .New, context: nil)
            
            self.titleLabel.text = song.name + " by " + song.artists[0].name
            
            var image : SPImage = song.album.cover as SPImage
            var coverImage:SPImage! = song.album.cover
            var loadedTrack : SPImage!
            var notLoaded : SPImage!
            SPAsyncLoading.waitUntilLoaded(coverImage, timeout: 10.0, then: {(
                loadedTrack, notLoaded) in self.setCoverImageAndPlaySong(coverImage.image, song: song)}
            )

            for item : AnyObject in self.view.subviews {
                if let button = item as? UIButton {
                    button.enabled = false
                }
            }
        }

    }
    
    func setCoverImageAndPlaySong(coverImage:UIImage, song:SPTrack) {
        
        self.doneButton.hidden = false
        var filter : GPUImagePixellateFilter = GPUImagePixellateFilter()
        self.currentTrackImage = song.album.cover.image
        self.songImageViewCopy.image = filter.imageByFilteringImage(song.album.cover.image)
        self.songImageViewCopy.layer.opacity = 1.0
        self.songImageViewCopy.hidden = false
        
        self.songImageView.image = song.album.cover.image
        
        stopWatch.start()
        
        self.spotifyController.startAndStop(song, after : 30)
        self.startAnimationForSong()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.removeObserver(self, forKeyPath: "spotifyController.search.tracks")
        self.removeObserver(self, forKeyPath: "spotifyController.search.playlists")
        self.removeObserver(self, forKeyPath: "spotifyController.loggedInUser")
        self.removeObserver(self, forKeyPath: "currentTrack.album.cover.image")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func logOut(sender : AnyObject) {

        self.spotifyController.logOut()
    }

    func forceEndSong() {
        self.playButton.enabled = true
        self.doneButton.enabled = false
        
        self.circleFill.removeAllAnimations()
        self.songImageViewCopy.layer.removeAllAnimations()
        
        self.circleFill.strokeEnd = 0.0;
        self.circleFill.fillColor = UIColor.clearColor().CGColor
        
        self.spotifyController.pause(self.currentTrack)
 
    }
    
    func songEndedPlaying(notification: NSNotification){
        self.playButton.enabled = true
        self.doneButton.enabled = false
        
        self.shuffleImageView.layer.opacity = 0.0

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = NSNumber.numberWithFloat(0.0)
        opacityAnimation.toValue = NSNumber.numberWithFloat(1.0)
        opacityAnimation.duration = 0.5
        
        self.shuffleImageView.layer.addAnimation(opacityAnimation, forKey: "opacity")
        self.shuffleImageView.layer.opacity = 1.0
        
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 1
        let initalBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 0, height: 0))
        let secondBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 10, height: 10))
        let finalBounds = NSValue(CGRect: self.shuffleImageView.bounds)
        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.4, 0.5]
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        
        self.shuffleImageView.layer.addAnimation(keyFrameAnimation, forKey: "bounds")
        
        self.background.image = self.currentTrackImage
        self.titleLabel.layer.addAnimation(opacityAnimation, forKey: "opacity")
        self.songTitleLabel.layer.addAnimation(opacityAnimation, forKey: "opacity")

        self.shuffleImageView.layer.opacity = 1.0
        self.titleLabel.layer.opacity = 1.0
        self.songTitleLabel.layer.opacity = 1.0
        self.playButton.hidden = false
        self.doneButton.hidden = true
        self.stopWatch.reset()
    }
}
