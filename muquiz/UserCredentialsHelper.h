//
//  NSUserDefaultsHelper.h
//  SpotifyLabb
//


#import <Foundation/Foundation.h>
#import "AuthenticationModel.h"

@interface UserCredentialsHelper : NSObject

-(void) saveUserName:(NSString *)userName andCredentials:(NSString *)credentials;
-(AuthenticationModel *) getSavedLoginCredentials;

-(void) removeSavedLoginCredentials;

@end
