//
//  NTAlbumsTableViewController.h
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTAlbumsTableViewControllerDelegate;

@interface NTAlbumsTableViewController : UITableViewController
@property (nonatomic) NSArray *albums;
@property (nonatomic, weak) id<NTAlbumsTableViewControllerDelegate> delegate;
@end

@protocol NTAlbumsTableViewControllerDelegate<NSObject>
- (void)albumsTableViewControllerDidSelectAlbum:(id)album;
@end
