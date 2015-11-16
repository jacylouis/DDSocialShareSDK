//
//  DDSinaHandle.h
//  HMLoginDemo
//
//  Created by lilingang on 15/8/1.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//
//QuartzCore.framework 、 ImageIO.framework 、 SystemConfiguration.framework 、 Security.framework 、CoreTelephony.framework 、 CoreText.framework 、 UIKit.framework 、 Foundation.framework 、 CoreGraphics.framework 、 libz.dylib 、 libsqlite3.dylib

#import <Foundation/Foundation.h>
#import "DDShareSDKEventHandlerDef.h"
#import "DDShareSDKContentProtocol.h"

@class UIViewController;

@interface DDSinaHandle : NSObject

@property (nonatomic, copy, readonly) NSString *appKey;

+ (BOOL)isSinaInstalled;

- (void)registerApp;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)authCompleteHandle:(DDAuthEventHandler)completeHandle;

- (void)getUserInfoCompleteHandle:(DDGetUserInfoEventHandler)completeHandle;

- (BOOL)shareWithProtocol:(id<DDShareSDKContentProtocol>)protocol
                     type:(DDSSShareType)shareType
           completeHandle:(DDShareContentEventHandler)completeHandle;

@end
