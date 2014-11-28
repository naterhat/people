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
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@end

@implementation NTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // create container for facebook login view
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [containerView setBackgroundColor:[UIColor colorWithWhite:0 alpha:.5f]];
    _facebookContainerView = containerView;
    
    // set background color
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_wood_texture.jpg"]]];
    
    [self.buttons setValue:@YES forKeyPath:@"hidden"];
    
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
        self.facebookLoginView = loginView;
        [self.facebookContainerView addSubview:self.facebookLoginView];
    }
    
    UIView *rootView = [[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController] view];
    [self.facebookContainerView setFrame:rootView.bounds];
    [self.facebookLoginView setCenter:self.facebookContainerView.center];
    [rootView addSubview:self.facebookContainerView];
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
    
    [self.buttons setValue:@NO forKeyPath:@"hidden"];
    [self.facebookContainerView removeFromSuperview];
    
    // get user data
    [self retrieveUserData];
}



- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"LOGGED OUT");
    
    // clear screen of buttons and title.
    [self.buttons setValue:@YES forKeyPath:@"hidden"];
    [self setTitle:@""];
}

@end
