//
//  DDWeChatHandle.h
//  HMLoginDemo
//
//  Created by lilingang on 15/7/31.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//
/// 开发者需要在工程中链接上:SystemConfiguration.framework,libz.dylib,libsqlite3.0.dylib,libc++.dylib
/// info.plist 配置 CFBundleURLName为weixin


#import <Foundation/Foundation.h>
#import "DDShareSDKEventHandlerDef.h"
#import "DDShareSDKContentProtocol.h"

@class DDLinkupItem;
@class UIViewController;

@interface DDWeChatHandle : NSObject

@property (nonatomic, copy, readonly) NSString *appKey;

+ (BOOL)isWeChatInstalled;

- (void)registerApp;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)getAuthCodeWithController:(UIViewController *)viewController
                   completeHandle:(DDAuthCodeEventHandler)completeHandle;

- (void)authWithController:(UIViewController *)viewController
            completeHandle:(DDAuthEventHandler)completeHandle;

- (void)getUserInfoCompleteHandle:(DDGetUserInfoEventHandler)completeHandle;

- (BOOL)shareWithProtocol:(id<DDShareSDKContentProtocol>)protocol
                    scene:(DDSSShareScene)shareScene
                     type:(DDSSShareType)shareType
           completeHandle:(DDShareContentEventHandler)completeHandle;

- (BOOL)linkupWithItem:(DDLinkupItem *)item;

@end
