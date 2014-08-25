//
//  AppDelegate.h
//  SpotifyLabb
//
//  Created by Arthur Onoszko on 09/07/14.
//  Copyright (c) 2014 arthur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotifyController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SpotifyController *spotifyController;

@end
