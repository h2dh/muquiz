//
//  NSUserDefaultsHelper.h
//  SpotifyLabb
//
//  Created by Arthur Onoszko on 10/07/14.
//  Copyright (c) 2014 arthur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationModel.h"

@interface UserCredentialsHelper : NSObject

-(void) saveUserName:(NSString *)userName andCredentials:(NSString *)credentials;
-(AuthenticationModel *) getSavedLoginCredentials;

-(void) removeSavedLoginCredentials;

@end
