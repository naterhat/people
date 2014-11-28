//
//  NTAlbumsTableViewController.m
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTAlbumsTableViewController.h"
#import "NTAlbumCollectionViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NTUser.h"
#import "NTGlobal.h"
#import "NTSocialInterface.h"
#import "UIAlertView+NTShow.h"

@interface NTAlbumsTableViewController ()
@property (nonatomic) id selectedAlbum;
@end

@implementation NTAlbumsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize if not.
    if (! _albums) _albums = [NSMutableArray array];
    
    [self setTitle:@"ALBUMS"];
    
    [self retrieveAlbums];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NTAlbumCollectionViewController *vc = (id)segue.destinationViewController;
    [vc setAlbum:self.selectedAlbum];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    // Configure the cell...
    NTAlbum *album = self.albums[indexPath.row];
    [cell.textLabel setText:album.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // dispatch back to the main view controller and pass the selected album.
    self.selectedAlbum = self.albums[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"album" sender:self];
}

#pragma mark -
#pragma mark - Other Functions

- (void)retrieveAlbums
{
    __weak typeof(self) weakself = self;
    [[NTSocialInterface sharedInstance] retrieveAlbumsWithHandler:^(NSArray *albums, NSError *error) {
        if(error) {
            [UIAlertView showAlertWithTitle:@"Error" andMessage:error.localizedDescription cancelTitle:nil];
        } else {
            // set data
            weakself.albums = albums;
            
            // reload table view
            [weakself.tableView reloadData];
        }
    } fromUser:[NTUser currentUser] forInterfaceType:NTSocialInterfaceTypeFacebook];
    
}



@end
