//
//  BaseViewController.m
//  SpotifyLabb
//
//  Created by Arthur Onoszko on 14/07/14.
//  Copyright (c) 2014 arthur. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
@implementation BaseViewController

-(SpotifyController *)spotifyController
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.spotifyController;
}
@end
 