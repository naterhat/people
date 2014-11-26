//
//  NTAlbumsTableViewController.m
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTAlbumsTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NTUser.h"
#import "NTGlobal.h"

@interface NTAlbumsTableViewController ()
@end

@implementation NTAlbumsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize if not.
    if (! _albums) _albums = [NSMutableArray array];
    
    [self retrieveAlbums];
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
//    if ([self.delegate respondsToSelector:@selector(albumsTableViewControllerDidSelectAlbum:)]) {
//        [self.delegate albumsTableViewControllerDidSelectAlbum:self.albums[indexPath.row]];
//    }
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


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
