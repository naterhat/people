//
//  UIImage+NTExtra.m
//  social_photos
//
//  Created by Nate on 11/27/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "UIImage+NTExtra.h"

@implementation UIImage (NTExtra)

+ (UIImage *)blendImage:(UIImage *)image withColor:(UIColor *)color
{
    if (!image) return nil;
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(image.size);
    
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    [color set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, bounds, [image CGImage]);
    CGContextFillRect(context, bounds);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

@end
