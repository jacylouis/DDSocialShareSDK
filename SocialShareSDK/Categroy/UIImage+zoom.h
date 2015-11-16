//
//  UIImage+zoom.h
//  MDLoginSDK
//
//  Created by lilingang on 15/10/14.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (zoom)

+ (NSData *)imageData:(NSData *)imageData maxBytes:(CGFloat)maxBytes;

@end
