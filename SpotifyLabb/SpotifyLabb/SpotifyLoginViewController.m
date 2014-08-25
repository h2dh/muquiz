//
//  SpotifyLoginViewController.m
//  SpotifyLabb
//
//  Created by Arthur Onoszko on 10/07/14.
//  Copyright (c) 2014 arthur. All rights reserved.
//

#import "SpotifyLoginViewController.h"
#import "SpotifyController.h"
#import "ViewController.h"

@interface SpotifyLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *loggedInUserNameLabel;

@end

@implementation SpotifyLoginViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        [self addObserver:self forKeyPath:@"spotifyController.loggedInUser" options:0 context:nil];
    [self.spotifyController tryLoginIfStoredCredentials];


    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    [self.spotifyController loginWithUserName:self.userNameTextField.text
                                  andPassword:self.passwordTextField.text];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"spotifyController.loggedInUser"])
    {
        self.loggedInUserNameLabel.text = self.spotifyController.loggedInUser;
        ViewController *viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        [self presentModalViewController:viewController animated:NO];
    }
}
-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"spotifyController.loggedInUser"];
}

@end
