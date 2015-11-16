//
//  DDSocialShareSDKHandle.h
//  DDSocialShareSDK
//
//  Created by lilingang on 15/8/12.
//  Copyright (c) 2015年 LeeLingang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDShareSDKEventHandlerDef.h"
#import "DDShareSDKContentProtocol.h"
#import "DDAuthItem.h"
#import "DDUserInfoItem.h"
#import "DDLinkupItem.h"

@class UIViewController;

@interface DDSocialShareSDKHandle : NSObject

+ (DDSocialShareSDKHandle *)sharedInstance;

- (void)clear;
/**
 *  判断客户端是否安装
 *
 *  @param platform 各应用平台
 *
 *  @return YES 已安装， NO 未安装
 */
+ (BOOL)isInstalledPlatform:(DDSSPlatform)platform;

/**
 *  返回第三方的appkey
 *
 *  @param platform 各应用平台
 *
 *  @return NSString appkey
 */
+ (NSString *)appkeyWithPlatform:(DDSSPlatform)platform;

/**
 *  在app启动的时候调用注册appid
 *  @note - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 *
 *  @param platform 各应用平台
 */
- (void)registerPlatform:(DDSSPlatform)platform;

/**
 *   AppDelegate中调用
 *  @note - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
 *
 *  @param url NSURL
 *
 *  @return YES 可以唤起
 */
- (BOOL)handleOpenURL:(NSURL *)url;


/**
 *  获取临时获取AuthInfo的code
 *  @warning 仅支持小米和微信
 *
 *  @param platform       各应用平台
 *  @param viewController 当前ViewController
 *  @param complateHandle 回调方法
 */
- (void)getAuthCodeWithPlatform:(DDSSPlatform)platform
                     controller:(UIViewController *)viewController
                 compleleHandle:(DDAuthCodeEventHandler)complateHandle;

/**
 *  授权方法
 *
 *  @param platform       各应用平台
 *  @param viewController 当前ViewController
 *  @param complateHandle 回调方法
 */
- (void)authWithPlatform:(DDSSPlatform)platform
              controller:(UIViewController *)viewController
          compleleHandle:(DDAuthEventHandler)complateHandle;

/**
 *  获取用户信息必须授权后才能获取
 *
 *  @param platform       各平台应用
 *  @param compleleHandle 回调方法
 */
- (void)getUserInfoWithPlatform:(DDSSPlatform)platform
                 compleleHandle:(DDGetUserInfoEventHandler)compleleHandle;

/**
 *  @brief  分享到第三方平台
 *
 *  @param platform       各平台应用
 *  @param shareScene     分享的场景
 *  @param shareType      分享数据类型
 *  @param protocol       遵循分享的数据组装的对象
 *  @param completeHandle 回调方法
 *
 *  @return 唤起成功返回YES,失败返回 NO
 */
- (BOOL)shareWithPlatform:(DDSSPlatform)platform
               shareScene:(DDSSShareScene)shareScene
                shareType:(DDSSShareType)shareType
                 protocol:(id<DDShareSDKContentProtocol>)protocol
           completeHandle:(DDShareContentEventHandler)completeHandle;

/**
 *  第三方接入
 *
 *  @param platform       各平台应用
 *  @param linkupItem     与第三方沟通需要的信息模型
 *
 *  @return 成功返回YES,失败返回 NO
 */
- (BOOL)linkupWithPlatform:(DDSSPlatform)platform
                      item:(DDLinkupItem *)linkupItem;

@end
