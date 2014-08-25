//
//  ViewController.h
//  SpotifyLabb
//
//  Created by Arthur Onoszko on 09/07/14.
//  Copyright (c) 2014 arthur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchbutton;
@property (weak, nonatomic) IBOutlet UITableView *resultTable;

@end
