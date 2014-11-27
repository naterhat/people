//
//  ViewController.m
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTHomeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NTAlbumsTableViewController.h"
#import "NTUser.h"
#import "NTGlobal.h"
#import "NTSocialInterface.h"
#import "UIAlertView+NTShow.h"

@interface NTHomeViewController () <FBLoginViewDelegate>
@property (nonatomic) FBLoginView *facebookLoginView;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSArray *albums;
@property (nonatomic) UIView *facebookContainerView;
@end

@implementation NTHomeViewController

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
        [loginView setPublishPermissions:@[@"publish_actions"]];
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
//    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        NTLogConnection(connection, result, error);
//        
//        [[NTUser currentUser] setName:result[@"name"]];
//        [[NTUser currentUser] setIdentifier:result[@"id"]];
//        
//        [weakself refreshView];
//    }];
    [[NTSocialInterface sharedInstance] retrieveUserWithHandler:^(NTUser *user, NSError *error) {
        if(error) {
            [UIAlertView showAlertWithTitle:@"Error" andMessage:@"Problem of connecting with facebook" cancelTitle:nil];
        } else {
            [[NTUser currentUser] setName:user.name];
            [[NTUser currentUser] setIdentifier:user.identifier];
            
            [weakself refreshView];
        }
    } forInterfaceType:NTSocialInterfaceTypeFacebook];
    
}

- (void)logout
{
    [[NTSocialInterface sharedInstance] logoutFromInterfaceType:NTSocialInterfaceTypeFacebook];
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

@end
