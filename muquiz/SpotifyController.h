//
//  SpotifyController.h
//  SpotifyLabb
//
//  Created by Arthur Onoszko on 10/07/14.
//  Copyright (c) 2014 arthur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"

@interface SpotifyController : NSObject

@property (nonatomic, strong) NSString *loggedInUser;

-(void) tryLoginIfStoredCredentials;
-(void) loginWithUserName:(NSString *)userName andPassword:(NSString *)password;
-(void) loginWithUserName:(NSString *)userName andExistingCredentials:(NSString *)credentials;
-(void) logOut;

@property (nonatomic, strong) SPSearch *search;
-(void) getSearchResultsWithSearchString:(NSString *)searchString;
-(void) getTracksForGenre:(NSString *)genre;

-(void) startPauseTrack:(SPTrack *)track;
-(BOOL) isPlayingSong;
-(void) startAndStop:(SPTrack *)track After:(NSInteger)seconds;

@end
