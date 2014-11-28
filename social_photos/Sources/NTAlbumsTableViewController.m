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
#import "UIActivityIndicatorView+NTShow.h"

@interface NTAlbumsTableViewController ()<UIAlertViewDelegate>
@property (nonatomic) id selectedAlbum;
@property (nonatomic) NSArray *albums;
@end

@implementation NTAlbumsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize if not.
    _albums = [NSArray array];
    
    [self setTitle:@"ALBUMS"];
    
    [self retrieveAlbums];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NTAlbumCollectionViewController *vc = (id)segue.destinationViewController;
    [vc setAlbum:self.selectedAlbum];
}

- (void)createAlbumWithName:(NSString *)name
{
    [UIActivityIndicatorView showIndicator];
    
    __weak typeof(self) weakself = self;
    [[NTSocialInterface sharedInstance] createNewAlbumWithName:name forUser:[NTUser currentUser] ofInterfaceType:NTSocialInterfaceTypeFacebook handler:^(BOOL success, NSError *error) {
        
        [UIActivityIndicatorView hideIndicator];
        
        // clear albums
        weakself.albums = @[];
        [weakself.tableView reloadData];
        
        // get new list of albums
        [weakself retrieveAlbums];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    if (indexPath.row == 0){
        [cell.textLabel setText:@"CREATE NEW ALBUM . . ."];
    } else {
        // Configure the cell...
        NTAlbum *album = self.albums[indexPath.row-1];
        [cell.textLabel setText:album.name];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        [UIActivityIndicatorView showIndicator];
        
        // alert user for the name of the new album
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create Album" message:@"Name for album?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
    } else {
        // go to album view controller
        // dispatch back to the main view controller and pass the selected album.
        self.selectedAlbum = self.albums[indexPath.row-1];
        
        [self performSegueWithIdentifier:@"album" sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        // cancel
    } else {
        NSString *name = [[alertView textFieldAtIndex:0] text];
        if (name.length  == 0) {
            [UIAlertView showAlertWithTitle:@"Error" andMessage:@"Name can't be empty." cancelTitle:nil];
            [UIActivityIndicatorView hideIndicator];
        } else {
            [self createAlbumWithName:name];
        }
    }
    
}




@end
