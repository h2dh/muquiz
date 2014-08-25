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
    
    
    /*
    @IBOutlet var button1 : UIButton!
    
    @IBAction func didPushButton1(sender : AnyObject) {
        var attributed = NSMutableAttributedString(string: self.button1.titleLabel.text, attributes: attributesForChoosenButton)
        self.button1.titleLabel.attributedText = attributed
        self.genrePick(self.button1.titleLabel.text)
        self.startAnimationForSong()
        
        self.setCurrentGenreForButton(self.button1)

        
    }
    @IBOutlet var button2 : UIButton!

    @IBAction func didPushButton2(sender : AnyObject) {
        var attributed = NSMutableAttributedString(string: self.button2.titleLabel.text, attributes: attributesForChoosenButton)
        self.button2.titleLabel.attributedText = attributed
        self.genrePick(self.button2.titleLabel.text)
        
        self.setCurrentGenreForButton(self.button2)
        self.startAnimationForSong()
        
    }
    @IBOutlet var button3 : UIButton!

    @IBAction func didPushButton3(sender : AnyObject) {
        var attributed = NSMutableAttributedString(string: self.button3.titleLabel.text, attributes: attributesForChoosenButton)
        self.button3.titleLabel.attributedText = attributed
        self.genrePick(self.button3.titleLabel.text)
        
        self.setCurrentGenreForButton(self.button3)
        self.startAnimationForSong()
    }
    @IBOutlet var button4 : UIButton!
    
    @IBAction func didPushButton4(sender : AnyObject) {
        var attributed = NSMutableAttributedString(string: self.button4.titleLabel.text, attributes: attributesForChoosenButton)
        self.button4.titleLabel.attributedText = attributed
        self.genrePick(self.button4.titleLabel.text)
        self.startAnimationForSong()
        
        self.setCurrentGenreForButton(self.button4)
    }
    @IBOutlet var button5 : UIButton!
    
    @IBAction func didPushButton5(sender : AnyObject) {
        var attributed = NSMutableAttributedString(string: self.button5.titleLabel.text, attributes: attributesForChoosenButton)
        self.button5.titleLabel.attributedText = attributed
        self.genrePick(self.button5.titleLabel.text)
        self.startAnimationForSong()
        
        self.setCurrentGenreForButton(self.button5)
    }
    @IBOutlet var button6 : UIButton!

    @IBAction func didPushButton6(sender : AnyObject) {
        var attributed = NSMutableAttributedString(string: self.button6.titleLabel.text, attributes: attributesForChoosenButton)
        self.button6.titleLabel.attributedText = attributed
        self.genrePick(self.button6.titleLabel.text)
        self.startAnimationForSong()
        self.setCurrentGenreForButton(self.button6)
    }


    
    @IBOutlet var searchImageView : UIImageView!
    
    func setCurrentGenreForButton(button : UIButton) {
        self.currentGenre = button.titleLabel.text
    }*/

    @IBOutlet var playButton : UIButton!
    
    func updateCurrentGenre(genre:String) {
        self.currentGenre = genre
    }
    

    func setPlaylistUserTop() {
        self.arrayWithSongs.addObjectsFromArray(self.userTopList.tracks)
    }
    
    func setPlaylistRegionTop() {
        self.arrayWithSongs.addObjectsFromArray(self.regionTopList.tracks)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.stopWatch = MZTimerLabel(label: self.ticker, andTimerType: MZTimerLabelTypeTimer)
        stopWatch.timeFormat = "SS"
        stopWatch.setCountDownTime(30000)
        
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
        attributesForChoosenButton = [NSForegroundColorAttributeName:UIColor.darkGrayColor(), NSStrokeWidthAttributeName:1]
        //self.currentGenre = self.button1.titleLabel.text
        
        //var attributed = NSMutableAttributedString(string: self.button1.titleLabel.text, attributes: attributesForChoosenButton)
       // self.button1.titleLabel.attributedText = attributed
        
        self.titleLabel.alpha = 0.0
        self.shuffleImageView.alpha = 1.0
        self.result = NSMutableArray()
        for item : AnyObject in self.view.subviews {
            if let button = item as? UIButton {
                button.alpha = 0.0
                button.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
            }
        }
        
        UIView.animateWithDuration(10.0, delay: 0.9, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations:{
            for item : AnyObject in self.view.subviews {
                if let button = item as? UIButton {
                    button.alpha = 1.0
                    button.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                }
            }
        }, completion: nil)
        
        self.songImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        
        var radius : CGFloat = songImageView.bounds.size.height/2.0;
        var layer :CAShapeLayer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: songImageView.bounds, cornerRadius: radius).CGPath
        songImageView.layer.mask = layer
        
        var radiusCopy : CGFloat = songImageViewCopy.bounds.size.height/2.0;
        var layerCopy :CAShapeLayer = CAShapeLayer()
        layerCopy.path = UIBezierPath(roundedRect: songImageViewCopy.bounds, cornerRadius: radiusCopy).CGPath
        songImageViewCopy.layer.mask = layerCopy
        
         songImageView.image.applyBlurWithRadius(15.0, tintColor: UIColor.whiteColor(), saturationDeltaFactor: 0.5, maskImage: nil)
        /*
        var blenddFilter : GPUImageAlphaBlendFilter = GPUImageAlphaBlendFilter()
        var imageToProcess : GPUImagePicture(i)
        
            GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
            GPUImagePicture *imageToProcess = [[GPUImagePicture alloc] initWithImage:self.imageToWorkWithView.image];
            GPUImagePicture *border = [[GPUImagePicture alloc] initWithImage:self.imageBorder];
            
            blendFilter.mix = 1.0f;
            [imageToProcess addTarget:blendFilter];
            [border addTarget:blendFilter];
            
            [imageToProcess processImage];
            self.imageToWorkWithView.image = [blendFilter imageFromCurrentlyProcessedOutput];
            
            [blendFilter release];
            [imageToProcess release];
            [border release];
        }*/
        
        //var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        //var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        //effectView.frame = self.songImageView.bounds
        
        self.circle.path = UIBezierPath(roundedRect: customView.bounds, cornerRadius: self.songImageView.bounds.size.height/2-15).CGPath
        self.circle.lineWidth = 28.0
        self.circle.strokeColor = UIColor.whiteColor().CGColor
        self.circle.strokeStart = 0.0
        self.circle.strokeEnd = 1.0
        self.circle.fillColor = self.view.backgroundColor!.CGColor
        
        self.circleFill.path = UIBezierPath(roundedRect: customView.bounds, cornerRadius: self.songImageView.bounds.size.height/2-20).CGPath
        self.circleFill.lineWidth = 15.0
        self.circleFill.strokeColor = UIColor(red: 255.0/255.0, green: 134.0/255.0, blue: 73.0/255.0, alpha: 1.0).CGColor
        self.circleFill.strokeStart = 0.0
        self.circleFill.strokeEnd = 1.0
        self.circleFill.fillColor = UIColor.clearColor().CGColor
        
        //self.songImageView.addSubview(effectView)
        self.songImageView.alpha = 0.5
        
        self.customView.layer.addSublayer(circle)
        self.customView.layer.addSublayer(self.circleFill)

        self.customView.alpha = 0.5
        self.customView.backgroundColor = self.view.backgroundColor
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
            var randomNumber = Int(arc4random_uniform(UInt32(self.arrayWithSongs.count)))
            
            var song : SPTrack = self.arrayWithSongs[randomNumber] as SPTrack
            var artist : SPArtist = song.artists[0] as SPArtist
            
            self.currentTrack = song
            
            self.addObserver(self, forKeyPath: "currentTrack.album.cover.image", options: .New, context: nil)
            
            self.titleLabel.text = song.name + " by " + song.artists[0].name
            
            var filter : GPUImagePixellateFilter = GPUImagePixellateFilter()
            
            
            
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initWithTrack(track:Track) {
        self.currentTrackTitle = track.title
        self.currentTrackImage = track.cover
    }
    
    func startAnimationForSong() {

        self.playButton.hidden = true
        self.circleFill.strokeStart = 0.0
        
        // Change the model layer's property first.
        self.circleFill.strokeEnd = 0.0;
        self.circleFill.strokeColor = UIColor.orangeColor().CGColor
        
        // Then apply the animation.
        var animation : CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 30
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.circleFill.addAnimation(animation, forKey: "strokeEnd")

        var colorAnimation : CABasicAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.fromValue = UIColor.redColor().CGColor
        colorAnimation.toValue = UIColor.orangeColor()
        colorAnimation.duration = 30
        colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.circleFill.addAnimation(colorAnimation, forKey: "strokeColor")
        
        self.songImageViewCopy.layer.opacity = 1.0
        
        let transitionFadeOut = CABasicAnimation(keyPath: "opacity")
        
       // transitionFadeOut.beginTime = CACurrentMediaTime() //add delay of 1 second
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
        
        //if keyPath == "spotifyController.search.tracks.album.cover" {
         //   self.songImageView.image = self.track?.cover
       // }
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
            
            var filter : GPUImagePixellateFilter = GPUImagePixellateFilter()


            
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
        var filter : GPUImagePixellateFilter = GPUImagePixellateFilter()
        
        self.songImageView.image = song.album.cover.image
        self.songImageViewCopy.image = song.album.cover.image
        self.songImageViewCopy.image = filter.imageByFilteringImage(self.songImageViewCopy.image)
        self.songImageViewCopy.alpha = 1.0
        self.songImageViewCopy.layer.opacity = 1.0
        self.blurryImageView.image = filter.imageByFilteringImage(self.blurryImageView.image)
        self.titleLabel.alpha = 1.0
        

        stopWatch.start()
        
        self.spotifyController.startAndStop(song, after : 30)
        self.startAnimationForSong()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.removeObserver(self, forKeyPath: "spotifyController.search.tracks")
        self.removeObserver(self, forKeyPath: "spotifyController.search.playlists")
        self.removeObserver(self, forKeyPath: "spotifyController.loggedInUser")
        self.removeObserver(self, forKeyPath: "currentTrack.album.cover.image")
        //self.removeObserver(self, forKeyPath: "spotifyController.search.tracks.album.cover")
    }

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func logOut(sender : AnyObject) {

        self.spotifyController.logOut()
    }

    func songEndedPlaying(notification: NSNotification){
        for item : AnyObject in self.view.subviews {
            if let button = item as? UIButton {
                button.enabled = true
            }
        }
        
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

        self.titleLabel.layer.addAnimation(opacityAnimation, forKey: "opacity")

        self.shuffleImageView.layer.opacity = 1.0
        self.titleLabel.layer.opacity = 1.0
        self.playButton.hidden = false
        self.stopWatch.reset()
    }
}
