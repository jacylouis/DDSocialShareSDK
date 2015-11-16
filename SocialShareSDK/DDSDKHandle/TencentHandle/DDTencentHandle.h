//
//  DDTencentHandle.h
//  HMLoginDemo
//
//  Created by lilingang on 15/8/1.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//
//添加SDK依赖的系统库文件。分别是”Security.framework”, “libiconv.dylib”，“SystemConfiguration.framework”，“CoreGraphics.Framework”、“libsqlite3.dylib”、“CoreTelephony.framework”、“libstdc++.dylib”、“libz.dylib”

#import <Foundation/Foundation.h>
#import "DDShareSDKEventHandlerDef.h"
#import "DDShareSDKContentProtocol.h"

@interface DDTencentHandle : NSObject

@property (nonatomic, copy, readonly) NSString *appKey;

+ (BOOL)isQQInstalled;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)authCompleteHandle:(DDAuthEventHandler)completeHandle;

- (void)getUserInfoCompleteHandle:(DDGetUserInfoEventHandler)completeHandle;

- (BOOL)shareWithProtocol:(id<DDShareSDKContentProtocol>)protocol
                    scene:(DDSSShareScene)shareScene
                     type:(DDSSShareType)shareType
           completeHandle:(DDShareContentEventHandler)completeHandle;
@end
