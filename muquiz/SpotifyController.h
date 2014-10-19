//
//  SpotifyController.h
//  SpotifyLabb
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"

@interface SpotifyController : NSObject

@property (nonatomic, strong) NSString *loggedInUser;
@property (nonatomic) BOOL successfullLogin;

-(void) tryLoginIfStoredCredentials;

-(void) loginWithUserName:(NSString *)userName andPassword:(NSString *)password;
-(void) loginWithUserName:(NSString *)userName andExistingCredentials:(NSString *)credentials;
-(void) logOut;

@property (nonatomic, strong) SPSearch *search;
-(void) getSearchResultsWithSearchString:(NSString *)searchString;
-(void) getTracksForGenre:(NSString *)genre;
-(void) getPlaylist:(NSString *)playlist;

-(void) startPauseTrack:(SPTrack *)track;
-(BOOL) isPlayingSong;
-(void) startAndStop:(SPTrack *)track After:(NSInteger)seconds;
-(void) pause:(SPTrack *)track;

@end
