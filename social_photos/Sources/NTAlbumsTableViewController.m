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

@interface NTAlbumsTableViewController ()
@property (nonatomic) id selectedAlbum;
@end

@implementation NTAlbumsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize if not.
    if (! _albums) _albums = [NSMutableArray array];
    
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
    
    // Configure the cell...
    id album = self.albums[indexPath.row];
    [cell.textLabel setText:album[@"name"]];
    [cell.detailTextLabel setText:album[@"id"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // dispatch back to the main view controller and pass the selected album.
    self.selectedAlbum = self.albums[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"album" sender:self];
}

- (void)uploadPhotos
{
    //    UIImage *image = [UIImage imageNamed:@"texture.jpg"];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"texture" withExtension:@"jpg"];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    NSString *encodeImage = [[NSString alloc] initWithData:imageData  encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            encodeImage, @"source",
                            nil
                            ];
    
    // 1) get albums
    // 2) select an albums
    // 3) open image picker
    // 4) select the images to upload
    // 5) upload the selected images to album
    // album id: 569065269905122"
    
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/{album-id}/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              NTLogConnection(connection, result, error);
                              /* handle the result */
                          }];
}

- (void)retrieveAlbums {
    NSString *userID = [[NTUser currentUser] identifier];
    if(!userID) return;
    
    __weak typeof(self) weakself = self;
    NSString *urlString = [NSString stringWithFormat:@"/%@/albums", userID];
    [FBRequestConnection startWithGraphPath:urlString completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NTLogConnection(connection, result, error);
        
        // set data
        weakself.albums = result[@"data"];
        
        // reload table view
        [weakself.tableView reloadData];
    }];
}



@end
