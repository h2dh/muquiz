//
//  PlayBoardViewController.swift
//  muquiz
//
//  Created by Hannah Reuterdahl on 11/08/14.
//  Copyright (c) 2014 game. All rights reserved.
//

import UIKit
import QuartzCore
import Foundation
import MediaPlayer

@IBDesignable
class PlayBoardViewController: UIViewController {
    
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
    
    var playlist : SPPlaylist = SPPlaylist();
    
    @IBOutlet weak var stopImageView: UIImageView!
    @IBOutlet weak var ticker: UILabel!
    var stopWatch : MZTimerLabel = MZTimerLabel()
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var songImageViewCopy: UIImageView!
    @IBOutlet weak var blurryImageView: UIImageView!
    var currentTrack:SPTrack = SPTrack()
    
    @IBOutlet weak var pickUpImage: UIImageView!
    var isObservingAlbum : Bool = false
    @IBOutlet weak var logoImageView: UIImageView!
    
    var result : NSMutableArray!
    var attributesForChoosenButton : NSDictionary!
    
    var savedTranslation : CGPoint = CGPoint()
    var originalcenterforvinyl : CGPoint = CGPoint()
    
    var mediaPlayer: MPMoviePlayerController = MPMoviePlayerController()
    var timer : NSTimer = NSTimer()

    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet var songImageView : UIImageView!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var vinylImage: UIImageView!
    @IBOutlet var customView : CustomView!
    @IBOutlet var playButton : UIButton!

    @IBOutlet weak var pointLabel: UILabel!
    

    
    func setPlaylistUserTop() {
        self.arrayWithSongs.addObjectsFromArray(self.userTopList.tracks)
       
    }
    
    func setPlaylistRegionTop() {
        self.arrayWithSongs.addObjectsFromArray(self.regionTopList.tracks)
    }
    
    override func viewWillAppear(animated: Bool) {

        var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        effectView.frame = self.background.bounds
        self.background.addSubview(effectView)
        
        self.stopImageView.layer.opacity = 0.0
        self.playImageView.layer.opacity = 1.0
        
        self.originalcenterforvinyl = self.vinylImage.layer.frame.origin
        
        self.playImageView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        self.vinylImage.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        self.logoImageView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        self.pickUpImage.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        self.songImageView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        self.songImageViewCopy.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        
        UIView.animateWithDuration(1.0, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            self.playImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            self.vinylImage.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            self.logoImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            self.pickUpImage.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            self.songImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            self.songImageViewCopy.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }), completion: nil)
    }
    
    //Stop song
    func leftSwipe(sender: UISwipeGestureRecognizer!){
        if !self.spotifyController.isPlayingSong() {
            self.playImageView.layer.opacity = 1.0
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = NSNumber.numberWithFloat(1.0)
            opacityAnimation.toValue = NSNumber.numberWithFloat(0.0)
            opacityAnimation.duration = 0.3
            
            if self.logoImageView.layer.opacity == 1.0 {
                self.logoImageView.layer.addAnimation(opacityAnimation, forKey: "opacity")
            }
            
            self.playImageView.layer.addAnimation(opacityAnimation, forKey: "opacity")
            self.playImageView.layer.opacity = 0.0
            self.logoImageView.layer.opacity = 0.0
            self.pickRandomSong();
        }
    }
    
    //Start new song
    func rightSwipe(sender: UISwipeGestureRecognizer!) {
        
        if self.spotifyController.isPlayingSong(){
            self.endSong()
        }
    }
    
    
    func changePoint(timer:NSTimer){
        if (self.pointLabel.text?.toInt() > 1 && self.pointLabel.text?.toInt()! < 6) {
            self.pointLabel.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
                self.pointLabel.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
            }), completion: nil)
            
            var newP: Int = self.pointLabel.text?.toInt() as Int!
            newP = newP - 1
            let xNSNumber = newP as NSNumber
            let xString : String = xNSNumber.stringValue
            self.pointLabel.text = xString
            
            self.pointLabel.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
            UIView.animateWithDuration(1.0, delay: 0.4, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
                self.pointLabel.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            }), completion: nil)
            
        } else {
            self.timer.invalidate()
            self.fadeIn(self.titleLabel.layer)
            self.fadeIn(self.songTitleLabel.layer)
            self.pointLabel.alpha = 0.0
        }
    }
    
    func setPlaylist() {
        
    }
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
      
        self.timer = NSTimer(timeInterval: 1.0, target: self, selector:"changePoint:", userInfo: nil, repeats: true)
        
        self.pointLabel.text = "5"
        self.pointLabel.alpha = 0.0
        
        let rightSwipeSelector : Selector = "rightSwipe:"
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: rightSwipeSelector)
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        
        self.vinylImage.addGestureRecognizer(rightSwipe)
        
        let leftSwipeSelector : Selector = "leftSwipe:"
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: leftSwipeSelector)
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        
        self.vinylImage.addGestureRecognizer(leftSwipe)
        
        var playlistArray : NSMutableArray = NSMutableArray();
        
        self.addObserver(self, forKeyPath: "spotifyController.search.playlists", options: .New, context: nil)
//        
//        self.spotifyController.search = SPSearch(searchQuery: "http://open.spotify.com/user/gmittleman/playlist/7k1A8KzvSD84CfGnQXu2SE", inSession: self.spotifyController.search.session)
        

        
        /*start
        self.pickUpImage.layer.transform = CATransform3DMakeRotation(5.14, 0.0, 0.0, 1.0)
       
        UIView.animateWithDuration(1.0, delay: 1.3, usingSpringWithDamping: 0.2, initialSpringVelocity: 10.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            self.pickUpImage.layer.transform = CATransform3DMakeRotation(0.0, 0.0, 0.0, 0.0)
        }), completion: nil)
        */
//        self.vinylImage.layer.shadowColor = UIColor.blackColor().CGColor
//        vinylImage.layer.shadowColor = UIColor.blackColor().CGColor;
//        vinylImage.layer.shadowOffset = CGSizeMake(0, 1);
//        vinylImage.layer.shadowOpacity = 1.0;
//        vinylImage.layer.shadowRadius = 1.0;
//        vinylImage.clipsToBounds = false;

        //self.navigationController.navigationBar.hidden = true
        
        self.songTitleLabel.alpha = 0.0
        
        self.stopWatch = MZTimerLabel(label: self.ticker, andTimerType: MZTimerLabelTypeTimer)
        stopWatch.timeFormat = "SS"
        stopWatch.setCountDownTime(30000)
    
        //var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        //var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        //effectView.frame = self.background.bounds
        //self.background.addSubview(effectView)
        
        //var filter : GPUImagePixellateFilter = GPUImagePixellateFilter()
        //var filter : GPUImageBoxBlurFilter = GPUImageBoxBlurFilter()
        //self.songImageView.image = filter.imageByFilteringImage(self.songImageView.image)
        
        //var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        //var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        //effectView.frame = self.background.bounds
        //self.background.addSubview(effectView)
        
        self.regionTopList = SPToplist(forLocale: SPSession.sharedSession().locale, inSession: SPSession.sharedSession())
        self.userTopList = SPToplist(forCurrentUserInSession: SPSession.sharedSession())
        
    
        self.spotifyController.getPlaylist("7k1A8KzvSD84CfGnQXu2SE")
        
        SPAsyncLoading.waitUntilLoaded(userTopList, timeout: 10.0, then: {(loadedUserTop, notLoadedUserTop) in self.setPlaylistUserTop()})
        
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
        self.playImageView.alpha = 1.0
        self.result = NSMutableArray()
        /*
        for item : AnyObject in self.view.subviews {
            if let button = item as? UIButton {
                button.alpha = 0.0
                button.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
            }
        }*/
        
     
        //self.songImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
       
//        var radius : CGFloat = songImageView.bounds.size.height/2.0;
//        var layer :CAShapeLayer = CAShapeLayer()
//        layer.path = UIBezierPath(roundedRect: songImageView.bounds, cornerRadius: radius).CGPath
//        songImageView.layer.mask = layer
//        
//        var radiusCopy : CGFloat = songImageViewCopy.bounds.size.height/2.0;
//        var layerCopy :CAShapeLayer = CAShapeLayer()
//        layerCopy.path = UIBezierPath(roundedRect: songImageViewCopy.bounds, cornerRadius: radiusCopy).CGPath
//        songImageViewCopy.layer.mask = layerCopy

        //self.songImageView.alpha = 1.0
        

        
        self.circleFill.path = UIBezierPath(roundedRect: customView.bounds, cornerRadius: self.customView.bounds.size.height/2-20).CGPath
        self.circleFill.lineWidth = 5.0
        self.circleFill.strokeColor = UIColor(red: 255.0/255.0, green: 127.0/255.0, blue: 102.0/255.0, alpha: 1.0).CGColor
        self.circleFill.strokeStart = 0.0
        self.circleFill.strokeEnd = 1.0
        self.circleFill.fillColor = UIColor.clearColor().CGColor

        self.circleFill.opacity = 0.0
//        self.songImageView.alpha = 1.0
        
        self.customView.layer.addSublayer(circle)
        self.customView.layer.addSublayer(self.circleFill)

        self.customView.alpha = 0.8
        self.customView.backgroundColor = UIColor.clearColor()
        
        
    }
    
    @IBAction func didPushPlayButton(sender : AnyObject) {


        
        self.pickRandomSong();
        //self.genrePick(self.currentGenre)
    }
    
    func pickRandomSong(){
        if self.arrayWithSongs.count > 0 {
            self.playImageView.alpha = 0.0
            self.titleLabel.alpha = 0.0
            self.songTitleLabel.alpha = 0.0
            var randomNumber = Int(arc4random_uniform(UInt32(self.arrayWithSongs.count)))
            
            var song : SPTrack = self.arrayWithSongs[randomNumber] as SPTrack
            var artist : SPArtist = song.artists[0] as SPArtist
            
            self.arrayWithSongs .removeObjectAtIndex(randomNumber)
            
            self.currentTrack = song
            
            self.addObserver(self, forKeyPath: "currentTrack.album.cover.image", options: .New, context: nil)
            self.isObservingAlbum = true
            
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func startAnimationForSong() {
        
        //self.timer = NSTimer(timeInterval: 5.0, target: self, selector:"changePoint:", userInfo: nil, repeats: true)
        self.timer.invalidate()
        self.playButton.enabled = false
        self.doneButton.enabled = true
        self.circleFill.strokeStart = 0.0
        self.pointLabel.alpha = 0.0
        
        //self.logoImageView.layer.opacity = 1.0
    //    self.songImageViewCopy.layer.opacity = 0.0
        // Change the model layer's property first.
        self.circleFill.opacity = 1.0
        self.circleFill.strokeEnd = 0.0
        
        
        // Then apply the animation.
        var animation : CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 30
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.circleFill.addAnimation(animation, forKey: "strokeEnd")

        var pixelAni : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        pixelAni.duration = 30
        pixelAni.fromValue = 0.0
        pixelAni.toValue = 1.0
        pixelAni.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
    //    self.songImageViewCopy.layer.addAnimation(pixelAni, forKey: "opacity")
        
        var rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(double: M_PI*2.0)
        rotation.duration = 30
        
        self.vinylImage.layer.addAnimation(rotation, forKey: "rotationAnimation")
      //  self.songImageView.layer.addAnimation(rotation, forKey: "rotationAnimation")
      //  self.songImageViewCopy.layer.addAnimation(rotation, forKey: "rotationAnimation")
        
        //Animate play button
        self.playImageView.layer.opacity = 1.0
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = NSNumber.numberWithFloat(1.0)
        opacityAnimation.toValue = NSNumber.numberWithFloat(0.0)
        opacityAnimation.duration = 0.3
        
        if self.logoImageView.alpha == 1.0 {
            self.logoImageView.layer.addAnimation(opacityAnimation, forKey: "opacity")
        }
        self.logoImageView.alpha = 0.0
        self.playImageView.layer.addAnimation(opacityAnimation, forKey: "opacity")
        self.playImageView.layer.opacity = 0.0
        
        UIView.animateWithDuration(0.5, delay: 0.1, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            self.playImageView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        }), completion: nil)
        
        
        let transitionFadeOut = CABasicAnimation(keyPath: "opacity")
        transitionFadeOut.duration = 0.3
        transitionFadeOut.fromValue = 1.0
        transitionFadeOut.toValue = 0.0
        transitionFadeOut.delegate = self
        transitionFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.playImageView.layer.addAnimation(transitionFadeOut, forKey: "opacity")
        self.playImageView.layer.opacity = 0.0
        self.playImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        

        //Animate stop button
        self.stopImageView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            self.stopImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }), completion: nil)
        self.stopImageView.layer.opacity = 1.0
        
        
        //Animate pixxeled image
     //   self.songImageViewCopy.layer.opacity = 1.0
        let transitionFadeOutImage = CABasicAnimation(keyPath: "opacity")
        
        transitionFadeOutImage.duration = 50
        transitionFadeOutImage.fromValue = 1.0
        transitionFadeOutImage.toValue = 0.0
        transitionFadeOutImage.delegate = self
        transitionFadeOutImage.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        
//        self.songImageViewCopy.layer.addAnimation(transitionFadeOutImage, forKey: "opacity")
//        self.songImageViewCopy.layer.opacity = 0.0

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
        
        if keyPath == "spotifyController.loggedOutUser" {
            self.spotifyController = nil;
        }
        
        
        if keyPath == "currentTrack.album.cover.image" {
            self.songImageViewCopy.image = self.currentTrack.album.cover.image
        }
        
        if keyPath == "spotifyController.search.playlists"{
            self.pickRandomSong()
        }
    }
    
    func chooseRandomSongForGenre(genre : String) {
        
        if self.result.count > 0 {
            self.playImageView.alpha = 0.0
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
        
        stopWatch.start()
        
        self.spotifyController.startAndStop(song, after : 30)
        self.startAnimationForSong()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.removeObserver(self, forKeyPath: "spotifyController.search.tracks")
        self.removeObserver(self, forKeyPath: "spotifyController.search.playlists")
        self.removeObserver(self, forKeyPath: "spotifyController.loggedInUser")
        
        if self.isObservingAlbum {
            self.removeObserver(self, forKeyPath: "currentTrack.album.cover.image")
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func logOut(sender : AnyObject) {

        self.spotifyController.logOut()
        self.view.hidden = true

    }
    
    @IBAction func didPushDoneButton(sender: AnyObject) {
        self.endSong()
    }
    
    func fadeOut(layer:CALayer) {
        let transitionFadeOut = CABasicAnimation(keyPath: "opacity")
        transitionFadeOut.duration = 0.2
        transitionFadeOut.fromValue = 1.0
        transitionFadeOut.toValue = 0.0
        transitionFadeOut.delegate = self
        transitionFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        layer.addAnimation(transitionFadeOut, forKey: "opacity")
        transitionFadeOut.duration = 0.2
        layer.opacity = 0.0
    }
    
    func fadeIn(layer:CALayer) {
        let transitionFadeIn = CABasicAnimation(keyPath: "opacity")
        transitionFadeIn.duration = 0.3
        transitionFadeIn.fromValue = 0.0
        transitionFadeIn.toValue = 1.0
        transitionFadeIn.delegate = self
        transitionFadeIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        layer.addAnimation(transitionFadeIn, forKey: "opacity")
        layer.opacity = 1.0
    }
    
    func bounceIn(layer:CALayer) {
        layer.opacity = 0.0
        
        layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        
        UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }), completion: nil)
    }
    
    
    func bounceOut(layer:CALayer) {
        layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        
        UIView.animateWithDuration(0.5, delay: 0.1, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        }), completion: nil)
    }
    

    func endSong() {
        
        self.spotifyController.pause(self.currentTrack)
        
        self.fadeIn(self.stopImageView.layer)
        self.fadeIn(self.pointLabel.layer)
        
        self.pointLabel.text = "5"
        self.timer = NSTimer(timeInterval: 1.0, target: self, selector:"changePoint:", userInfo: nil, repeats: true)
        
        NSRunLoop.mainRunLoop().addTimer(self.timer, forMode:NSDefaultRunLoopMode)
        
        self.playButton.enabled = true
        self.doneButton.enabled = false
        
        if (self.logoImageView.alpha == 1.0) {
            self.fadeOut(self.logoImageView.layer)
        }
        
        self.circleFill.removeAllAnimations()
        self.vinylImage.layer.removeAllAnimations()
        
        self.circleFill.strokeEnd = 0.0;
        self.circleFill.fillColor = UIColor.clearColor().CGColor
        
        self.bounceIn(self.playImageView.layer)
        self.bounceOut(self.stopImageView.layer)
        
        self.fadeIn(self.playImageView.layer)
        
        self.fadeOut(self.stopImageView.layer)

        self.stopWatch.reset()
        
    }
    
    func songEndedPlaying(notification: NSNotification){
        
        self.endSong()
        
//        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
//        keyFrameAnimation.delegate = self
//        keyFrameAnimation.duration = 1
//        let initalBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 0, height: 0))
//        let secondBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 10, height: 10))
//        let finalBounds = NSValue(CGRect: self.playImageView.bounds)
//        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
//        keyFrameAnimation.keyTimes = [0, 0.4, 0.5]
//        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
//        
//        self.playImageView.layer.addAnimation(keyFrameAnimation, forKey: "bounds")
        
        //self.background.image = self.currentTrackImage
//        self.titleLabel.layer.addAnimation(opacityAnimation, forKey: "opacity")
//        self.songTitleLabel.layer.addAnimation(opacityAnimation, forKey: "opacity")

        
        
      //  self.pointLabel.alpha = 0.0
        //self.pointLabel.text = "6"
    }
    
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "logoutsegue")
        {
            let loginVC : LoginViewController = segue.destinationViewController as LoginViewController
            loginVC.spotifyController = self.spotifyController
       }
   }
    
    
    func animateVinylIn()
    {
        self.vinylImage.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        let point : CGPoint = self.originalcenterforvinyl
        UIView.animateWithDuration(1.0, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            self.vinylImage.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            //    self.songImageViewCopy.layer.transform = CATransform3DMakeTranslation(100.0, 100.0, 100.0)
        }), completion: nil)
    }
    
    
}
