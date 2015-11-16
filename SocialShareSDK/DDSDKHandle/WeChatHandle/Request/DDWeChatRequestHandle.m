//
//  DDWeChatRequestHandle.m
//  HMLoginDemo
//
//  Created by lilingang on 15/7/31.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDWeChatRequestHandle.h"

NSString *const DDWeChatHostName =            @"https://api.weixin.qq.com/";
NSString *const DDWeChatAPINameAccessToken =  @"sns/oauth2/access_token";
NSString *const DDWeChatAPINameUserInfo =     @"sns/userinfo";


@implementation DDWeChatRequestHandle

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
        compleleHandle:(DDWeChatRequestBlock)compleleHandle{
    NSError *error = nil;
    if (![appid length]) {
        error = [NSError errorWithDomain:@"Parames Error" code:1990 userInfo:@{@"description":@"appid 为空"}];
    }
    if (![secret length]) {
        error = [NSError errorWithDomain:@"Parames Error" code:1990 userInfo:@{@"description":@"secret 为空"}];
    }
    if (![code length]) {
        error = [NSError errorWithDomain:@"Parames Error" code:1990 userInfo:@{@"description":@"code 为空"}];
    }
    
    if (error) {
        if (compleleHandle) {
            compleleHandle(nil,error);
        }
        return;
    }
    
    NSDictionary *dict = @{
                           @"appid":appid,
                           @"secret":secret,
                           @"code":code,
                           @"grant_type":@"authorization_code",
                           };
    [self baseSendAsynchronousWithHostname:DDWeChatHostName
                                   apiName:DDWeChatAPINameAccessToken
                                    params:dict
                            completeHandle:^(NSDictionary *responseDict, NSError *connectionError) {
                                if (connectionError) {
                                    if (compleleHandle) {
                                        compleleHandle(nil,connectionError);
                                    }
                                }
                                else {
                                    NSInteger errcode = [responseDict[@"errcode"] integerValue];
                                    if (errcode != 0) {
                                        NSString *errmsg = responseDict[@"errmsg"];
                                        NSError *error = [NSError errorWithDomain:@"Wechat Request ERROR" code:errcode userInfo:@{@"description":errmsg}];
                                        if (compleleHandle) {
                                            compleleHandle(nil,error);
                                        }
                                    }
                                    else {
                                        if (compleleHandle) {
                                            compleleHandle(responseDict,nil);
                                        }
                                    }
                                }
                            }];
}

/**
 *  获取用户信息
 *
 *  @param accessToken    获取的accessToken
 *  @param openid         获取token时返回的openid
 *  @param compleleHandle 回调
 */
+ (void)userInfoWithToken:(NSString *)accessToken
                   openid:(NSString *)openid
           compleleHandle:(DDWeChatRequestBlock)compleleHandle{
    NSError *error = nil;
    if (![accessToken length]) {
        error = [NSError errorWithDomain:@"Parames Error" code:1990 userInfo:@{@"description":@"access_token 为空"}];
    }
    if (![openid length]) {
        error = [NSError errorWithDomain:@"Parames Error" code:1990 userInfo:@{@"description":@"openid 为空"}];
    }
    if (error) {
        if (compleleHandle) {
            compleleHandle(nil,error);
        }
        return;
    }
    NSDictionary *dict = @{
                           @"access_token":accessToken,
                           @"openid":openid,
                           };
    [self baseSendAsynchronousWithHostname:DDWeChatHostName
                                   apiName:DDWeChatAPINameUserInfo
                                    params:dict
                            completeHandle:^(NSDictionary *responseDict, NSError *connectionError) {
                                if (connectionError) {
                                    if (compleleHandle) {
                                        compleleHandle(nil,connectionError);
                                    }
                                }
                                else {
                                    NSInteger errcode = [responseDict[@"errcode"] integerValue];
                                    if (errcode != 0) {
                                        NSString *errmsg = responseDict[@"errmsg"];
                                        NSError *error = [NSError errorWithDomain:@"Wechat Request ERROR" code:errcode userInfo:@{@"description":errmsg}];
                                        if (compleleHandle) {
                                            compleleHandle(nil,error);
                                        }
                                    }
                                    else {
                                        if (compleleHandle) {
                                            compleleHandle(responseDict,nil);
                                        }
                                    }
                                }
                            }];
}


#pragma mark - Private Methods

/**
 *  基础的网络请求方法
 *
 *  @param hostName       hostName e.g. http://wwww.baidu.com/
 *  @param apiName        apiName e.g.  sns/userinfo
 *  @param params         params 参数 NSDictionary
 *  @param compleleHandle 请求回调
 */
+ (void)baseSendAsynchronousWithHostname:(NSString *)hostName
                                 apiName:(NSString *)apiName
                                  params:(NSDictionary *)params
                          completeHandle:(DDWeChatRequestBlock)compleleHandle{
    NSString *urlString = [hostName stringByAppendingString:apiName];
    NSString *paramString = @"";
    for (NSString *keyString in [params allKeys]) {
        NSString *value = params[keyString];
        paramString = [paramString stringByAppendingFormat:@"%@=%@&",keyString,value];
    }
    paramString  = [paramString substringToIndex:[paramString length] - 1];
    urlString = [[urlString stringByAppendingString:@"?"] stringByAppendingString:paramString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (compleleHandle) {
            if (error) {
                compleleHandle(nil,error);
            }
            else {
                compleleHandle(jsonDict,connectionError);
            }
        }
    }];
}

@end
