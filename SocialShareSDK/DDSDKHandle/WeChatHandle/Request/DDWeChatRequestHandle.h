//
//  DDWeChatRequestHandle.h
//  HMLoginDemo
//
//  Created by lilingang on 15/7/31.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  网络请求回调
 *
 *  @param responseDict    响应的数据
 *  @param connectionError 错误
 */
typedef void (^DDWeChatRequestBlock) (NSDictionary *responseDict, NSError *connectionError);

@interface DDWeChatRequestHandle : NSObject

/**
 *  获取AccessToken
 *
 *  @param appid          申请应用的appid
 *  @param secret         申请应用的appSecret
 *  @param code           向微信请求snsapi_userinfo scope 返回的code
 *  @param compleleHandle 回调
 */
+ (void)tokenWithAppid:(NSString *)appid
                secret:(NSString *)secret
                  code:(NSString *)code
        compleleHandle:(DDWeChatRequestBlock)compleleHandle;

/**
 *  获取用户信息
 *
 *  @param accessToken    获取的accessToken
 *  @param openid         获取token时返回的openid
 *  @param compleleHandle 回调
 */
+ (void)userInfoWithToken:(NSString *)accessToken
                   openid:(NSString *)openid
           compleleHandle:(DDWeChatRequestBlock)compleleHandle;

@end
