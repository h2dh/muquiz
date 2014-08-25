//
//  ViewController.m
//  SpotifyLabb
//
//  Created by Arthur Onoszko on 09/07/14.
//  Copyright (c) 2014 arthur. All rights reserved.
//

#import "ViewController.h"
#import "CocoaLibSpotify.h"
#import "SpotifyController.h"



@interface ViewController ()
@property (nonatomic, strong) NSArray *result;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genrePicker;
@property (weak, nonatomic) IBOutlet UILabel *loggedInUser;
@end

@implementation ViewController
- (IBAction)genrePick:(id)sender
{

    NSString *genre = [self.genrePicker titleForSegmentAtIndex:[self.genrePicker selectedSegmentIndex]];
    [self.spotifyController getTracksForGenre:genre];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.result.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    SPTrack *track = self.result[indexPath.row];
    SPArtist *artist = track.artists[0];
    cell.textLabel.text = track.name;
    cell.detailTextLabel.text = artist.name;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPTrack *track = self.result[indexPath.row];
    [self.spotifyController startPauseTrack:track];
    
}
- (IBAction)search:(id)sender
{
    NSString *searchString = self.searchField.text;
    [self.spotifyController getSearchResultsWithSearchString:searchString];
    //self.search = [SPSearch searchWithSearchQuery:searchString inSession:[SPSession sharedSession]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.resultTable.dataSource = self;
    self.resultTable.delegate = self;
    [self addObserver:self forKeyPath:@"spotifyController.search.tracks" options:0 context:nil];
    [self addObserver:self forKeyPath:@"spotifyController.loggedInUser" options:0 context:nil];
    self.loggedInUser.text = self.spotifyController.loggedInUser;


}
- (IBAction)logOut:(id)sender
{
    [self.spotifyController logOut];
}

-(void)viewDidAppear:(BOOL)animated
{

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"spotifyController.search.tracks"])
    {
        self.result = self.spotifyController.search.tracks;
        if(self.result.count)
        {
            [self.resultTable reloadData];
        }
        
    }
    if([keyPath isEqualToString:@"spotifyController.loggedInUser"])
    {
        self.loggedInUser.text = self.spotifyController.loggedInUser;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
