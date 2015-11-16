//
//  DDMIHandle.h
//  HMLoginDemo
//
//  Created by lilingang on 15/8/3.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//
/// info.plist 配置 CFBundleURLName为xiaomi

#import <Foundation/Foundation.h>
#import "DDShareSDKEventHandlerDef.h"

@class UIViewController;

@interface DDMIHandle : NSObject

@property (nonatomic, copy, readonly) NSString *appKey;

- (void)getAuthCodeWithController:(UIViewController *)viewController
                   completeHandle:(DDAuthCodeEventHandler)completeHandle;

- (void)authWithController:(UIViewController *)viewController
            completeHandle:(DDAuthEventHandler)completeHandle;

- (void)getUserInfoCompleteHandle:(DDGetUserInfoEventHandler)completeHandle;

@end
