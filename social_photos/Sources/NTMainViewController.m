//
//  ViewController.m
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTMainViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NTAlbumsTableViewController.h"

@interface NTMainViewController () <FBLoginViewDelegate, NTAlbumsTableViewControllerDelegate>
@property (nonatomic) FBLoginView *facebookLoginView;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSArray *albums;
@property (nonatomic) id selectedAlbum;
@end

@implementation NTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    FBLoginView *loginView = [[FBLoginView alloc] init];
    [loginView setReadPermissions:@[@"user_photos"]];
    [loginView setDelegate:self];
    [loginView setLoginBehavior:FBSessionLoginBehaviorForcingWebView];
    loginView.center = self.view.center;
    [self.view addSubview:loginView];
    _facebookLoginView = loginView;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.destinationViewController isKindOfClass:[NTAlbumsTableViewController class]] ) {
        NTAlbumsTableViewController *vc = segue.destinationViewController;
        [vc setAlbums:self.albums];
        [vc setDelegate:self];
    }
    
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"LOGGED IN");
    [_facebookLoginView removeFromSuperview];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"LOGGED OUT");
}
- (IBAction)selectFacebook:(id)sender {
    [self.view addSubview:_facebookLoginView];
}

- (IBAction)selectUpload:(id)sender {
}

- (IBAction)selectPhotos:(id)sender {
    
}

- (IBAction)selectAlbums:(id)sender
{
    
}

- (IBAction)selectLogout:(id)sender
{
    [[FBSession activeSession] closeAndClearTokenInformation];
}

- (void)logTitle:(NSString *)title content:(id)content
{
    NSLog(@"\n%@ ====================\n%@", title, content);
}

- (IBAction)selectMe:(id)sender {
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"connection: %@", connection);
        [self logTitle:@"me" content:result];
        self.userID = result[@"id"];
    }];
}

- (IBAction)selectAlbums:(id)sender {
    if(!self.userID) return;
    NSString *urlString = [NSString stringWithFormat:@"/%@/albums", self.userID];
    [FBRequestConnection startWithGraphPath:urlString completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"connection: %@", connection);
        [self logTitle:@"albums" content:result];
        self.albums = result[@"data"];
        
        if(self.albums.count) {
            [self performSegueWithIdentifier:@"albums" sender:self];
        }
    }];
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
                              /* handle the result */
                          }];
}

#pragma mark -
#pragma mark - Albums Table View Controller Delegate

- (void)albumsTableViewControllerDidSelectAlbum:(id)album
{
    [self.navigationController popViewControllerAnimated:YES];
    self.selectedAlbum = album;
    
    [self logTitle:@"selected album" content:self.selectedAlbum];
}

@end
