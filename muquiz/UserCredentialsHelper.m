//
//  NSUserDefaultsHelper.m
//  SpotifyLabb
//
//  Created by Arthur Onoszko on 10/07/14.
//  Copyright (c) 2014 arthur. All rights reserved.
//

#import "UserCredentialsHelper.h"
#define SPOTIFY_USERNAME_KEY @"userName"
#define SPOTIFY_CREDENTIALS_KEY @"credentials"
#define SPOTIFY_LOGIN_CREDENTIALS_KEY @"SpotifyLoginCredentials"
@interface UserCredentialsHelper()
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation UserCredentialsHelper

-(NSUserDefaults *) userDefaults
{
    if(_userDefaults == nil)
    {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return _userDefaults;
}

-(void)saveUserName:(NSString *)userName andCredentials:(NSString *)credentials
{
    NSDictionary *loginCredentials = [[NSDictionary alloc] initWithObjects:@[userName, credentials] forKeys:@[SPOTIFY_USERNAME_KEY,SPOTIFY_CREDENTIALS_KEY]];
    [self.userDefaults setObject:loginCredentials forKey:SPOTIFY_LOGIN_CREDENTIALS_KEY];
    [self.userDefaults synchronize];
}

-(AuthenticationModel *)getSavedLoginCredentials
{
    NSDictionary *loginCredentials = [self.userDefaults objectForKey:SPOTIFY_LOGIN_CREDENTIALS_KEY];
    AuthenticationModel *authenticationModel = [AuthenticationModel new];
    authenticationModel.userName = [loginCredentials objectForKey:SPOTIFY_USERNAME_KEY];
    authenticationModel.credentials = [loginCredentials objectForKey:SPOTIFY_CREDENTIALS_KEY];
    return authenticationModel;
    
}

-(void) removeSavedLoginCredentials
{
    [self.userDefaults removeObjectForKey:SPOTIFY_LOGIN_CREDENTIALS_KEY];
    [self.userDefaults synchronize];
}
@end
