//
//  UIImage+zoom.m
//  MDLoginSDK
//
//  Created by lilingang on 15/10/14.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "UIImage+zoom.h"

@implementation UIImage (zoom)

+ (NSData *)imageData:(NSData *)imageData maxBytes:(CGFloat)maxBytes{
    if (imageData.length < maxBytes) {
        return imageData;
    }
    UIImage *image = [UIImage imageWithData:imageData];
    CGFloat scale = sqrt([imageData length]/maxBytes)*[UIScreen mainScreen].scale;
    CGFloat newWidth = floorf(image.size.width/scale);
    CGFloat newHeight = floorf(image.size.height/scale);
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImagePNGRepresentation(scaledImage);
}

@end
