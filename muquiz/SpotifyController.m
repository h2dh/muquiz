//
//  SpotifyController.m
//  SpotifyLabb
//

#import "SpotifyController.h"
#import "CocoaLibSpotify.h"
#include "appkey.c"
#import "UserCredentialsHelper.h"

@interface SpotifyController() <SPSessionDelegate, SPPlaybackManagerDelegate>
@property (nonatomic, strong) SPSession *spotifySession;
@property (nonatomic, strong) UserCredentialsHelper *userDefaultsHelper;
@property (nonatomic, strong) SPPlaybackManager *playbackManager;
@property (nonatomic, strong) SPTrack *currentTrack;
@property (nonatomic, strong) NSTimer* timer;


@end

@implementation SpotifyController
-(BOOL)isPlayingSong
{
    return [self.playbackManager isPlaying];
}
-(UserCredentialsHelper *) userDefaultsHelper
{
    if(_userDefaultsHelper == nil)
    {
        _userDefaultsHelper = [UserCredentialsHelper new];
    }
    return _userDefaultsHelper;
}

-(SPPlaybackManager *)playbackManager
{
    if(_playbackManager == nil)
    {
        _playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:self.spotifySession];
    }
    return _playbackManager;
}
-(SPSession *)spotifySession
{
    if([SPSession sharedSession] == nil)
    {
        NSString *userAgent = [[[NSBundle mainBundle] infoDictionary] valueForKey:(__bridge NSString *)kCFBundleIdentifierKey];
        NSData *appKey = [NSData dataWithBytes:&g_appkey length:g_appkey_size];
        NSError *error = nil;

        [SPSession initializeSharedSessionWithApplicationKey:appKey
                                                   userAgent:userAgent
                                               loadingPolicy:SPAsyncLoadingManual
                                                       error:&error];
        
        if(error != nil)
        {
            NSLog(@"CocoaLibSpotify init failed: %@", error);
            abort();
        }
        
        [[SPSession sharedSession] setDelegate:self];

    }
    return [SPSession sharedSession];
}

-(void)tryLoginIfStoredCredentials
{
    AuthenticationModel *authenticatedUser = [self.userDefaultsHelper getSavedLoginCredentials];
    if(authenticatedUser.userName)
    {
        [self loginWithUserName:authenticatedUser.userName andExistingCredentials:authenticatedUser.credentials];
        //self.successfullLogin = YES;
    } else {
       // self.successfullLogin = NO;
    }

}

-(void)loginWithUserName:(NSString *)userName andPassword:(NSString *)password
{
    [self.spotifySession attemptLoginWithUserName:userName password:password];
}
-(void)loginWithUserName:(NSString *)userName andExistingCredentials:(NSString *)credentials
{
    [self.spotifySession attemptLoginWithUserName:userName existingCredential:credentials];
}
-(void)logOut
{
    [self.spotifySession logout:^{
        [self.userDefaultsHelper removeSavedLoginCredentials];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loggedInUser = nil;

        });
    }];
}
-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName
{
    NSLog(@"didGenerateLoginCredentials userName:%@",userName);
    [self.userDefaultsHelper saveUserName:userName andCredentials:credential];
    self.loggedInUser = userName;
}
-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error
{
    
    NSLog(@"failToLoginWithError %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
}
-(void)sessionDidLoginSuccessfully:(SPSession *)aSession
{
    NSLog(@"didLogin");
    
}
-(void) getTracksForGenre:(NSString *)genre
{
    self.search = [[SPSearch alloc] initWithSearchQuery:[NSString stringWithFormat:@"genre:%@",genre] inSession:self.spotifySession];
}

-(void) getPlaylist:(NSString *)playlist
{
    //self.search = [[SPSearch alloc] initWithSearchQuery:@"playlist:29Kx4MijwHzwwTSftv5zjN" inSession:self.spotifySession];
}

-(void) getSearchResultsWithSearchString:(NSString *)searchString
{
    self.search = [[SPSearch alloc] initWithSearchQuery:searchString inSession:self.spotifySession];
}
-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage
{
    NSLog(@"Message for user %@",aMessage);
}
-(void)sessionDidLogOut:(SPSession *)aSession
{
    NSLog(@"didLogOut");
}
-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error{
    NSLog(@"didEncounterNetworkError");
    
}
-(void)session:(SPSession *)aSession didEncounterScrobblingError:(NSError *)error{
    NSLog(@"didEncounterScrobblingError");
}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage
{
    NSLog(@"Log Message %@", aMessage);
}

-(void) pause:(SPTrack *)track {
    [self pausePlayMusic];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"kSPSongEnded" object:nil];
    [self.timer invalidate];
}
-(void) startPauseTrack:(SPTrack *)track
{    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kSPSongEnded" object:nil];
    if(self.playbackManager.isPlaying)
    {
        if([self.currentTrack isEqual:track])
        {
            [self pausePlayMusic];
        }
        else
        {
            [self startPlayingTrack:track];
        }
    }
    else
    {
        if([self.currentTrack isEqual:track])
        {
            [self resumePlayMusic];
        }
        else
        {
            [self startPlayingTrack:track];
        }
    }
}

-(void)startAndStop:(SPTrack *)track After:(NSInteger)seconds{
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self
                                                      selector: @selector(songDone:) userInfo: nil repeats: YES];
    [self startPlayingTrack:track];
    
}

-(void)songDone:(NSTimer*) timer {
    [self pausePlayMusic];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kSPSongEnded" object:nil];
    [self.timer invalidate];
}

-(void) startPlayingTrack:(SPTrack *)trackToPlay
{
    [SPAsyncLoading waitUntilLoaded:trackToPlay timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
        [self.playbackManager playTrack:trackToPlay callback:^(NSError *error) {
            if(error)
            {
              NSLog(@"Could not play track");  
            }
            else
            {
                self.currentTrack = trackToPlay;
            }
            
        }];
    }];
    
}
-(void) resumePlayMusic
{
    self.playbackManager.isPlaying = YES;
}
-(void) pausePlayMusic
{
    self.playbackManager.isPlaying = NO;
}
-(void)playbackManagerWillStartPlayingAudio:(SPPlaybackManager *)aPlaybackManager
{
    
}
@end
