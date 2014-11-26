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
#import "NTUser.h"
#import "NTGlobal.h"

@interface NTMainViewController () <FBLoginViewDelegate>
@property (nonatomic) FBLoginView *facebookLoginView;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSArray *albums;
@property (nonatomic) id selectedAlbum;
@property (nonatomic) UIView *facebookContainerView;
@end

@implementation NTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [containerView setBackgroundColor:[UIColor colorWithWhite:0 alpha:.5f]];
    _facebookContainerView = containerView;
    
    [self login];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)selectPhotos:(id)sender {
    
}

- (IBAction)selectLogout:(id)sender
{
    [self logout];
    [self login];
}

- (IBAction)selectMe:(id)sender
{
    [self retrieveUserData];
}

- (IBAction)selectAlbums:(id)sender
{
    [self performSegueWithIdentifier:@"albums" sender:self];
}


#pragma mark -
#pragma mark - Other Functions

- (void)login
{
    if(! _facebookLoginView ) {
        // set login view
        FBLoginView *loginView = [[FBLoginView alloc] init];
        [loginView setReadPermissions:@[@"user_photos"]];
        [loginView setDelegate:self];
        [loginView setLoginBehavior:FBSessionLoginBehaviorForcingWebView];
        loginView.center = self.view.center;
        self.facebookLoginView = loginView;
        [self.facebookContainerView addSubview:self.facebookLoginView];
    }
    
    [self.view addSubview:self.facebookContainerView];
}

- (void)refreshView
{
    // check if have user data. If not, get user data
    if( ! [[NTUser currentUser] loaded] ) {
        NSLog(@"User Data not loaded");
        [self retrieveUserData];
        return;
    }
    
    // set title name
    self.title = [[NTUser currentUser] name];
}

- (void)retrieveUserData
{
    __weak typeof(self) weakself = self;
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NTLogConnection(connection, result, error);
        
        [[NTUser currentUser] setName:result[@"name"]];
        [[NTUser currentUser] setIdentifier:result[@"id"]];
        
        [weakself refreshView];
    }];
}

- (void)logout
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[NTUser currentUser] clearAndSave];
}

#pragma mark -
#pragma mark - Facebook Login View Delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"LOGGED IN");
    [self.facebookContainerView removeFromSuperview];
    
    // get user data
    [self retrieveUserData];
}



- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"LOGGED OUT");
}

//- (void)uploadPhotos
//{
////    UIImage *image = [UIImage imageNamed:@"texture.jpg"];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"texture" withExtension:@"jpg"];
//    NSData *imageData = [NSData dataWithContentsOfURL:url];
//    NSString *encodeImage = [[NSString alloc] initWithData:imageData  encoding:NSUTF8StringEncoding];
//    
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            encodeImage, @"source",
//                            nil
//                            ];
//    
//    // 1) get albums
//    // 2) select an albums
//    // 3) open image picker
//    // 4) select the images to upload
//    // 5) upload the selected images to album
//    // album id: 569065269905122"
//    
//    /* make the API call */
//    [FBRequestConnection startWithGraphPath:@"/{album-id}/photos"
//                                 parameters:params
//                                 HTTPMethod:@"POST"
//                          completionHandler:^(
//                                              FBRequestConnection *connection,
//                                              id result,
//                                              NSError *error
//                                              ) {
//                              NTLogConnection(connection, result, error);
//                              /* handle the result */
//                          }];
//}

//#pragma mark -
//#pragma mark - Albums Table View Controller Delegate
//
//- (void)albumsTableViewControllerDidSelectAlbum:(id)album
//{
//    [self.navigationController popViewControllerAnimated:YES];
//    self.selectedAlbum = album;
//    
//    NTLogTitleMessage(@"selected album", self.selectedAlbum);
//}

@end
