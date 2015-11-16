//
//  DDSinaRequestHandle.m
//  HMLoginDemo
//
//  Created by lilingang on 15/8/2.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDSinaRequestHandle.h"

NSString *const DDSinaHostName =            @"https://api.weibo.com/";
NSString *const DDSinaAPINameUID =          @"2/account/get_uid.json";
NSString *const DDSinaAPINameUserInfo =     @"2/users/show.json";

@implementation DDSinaRequestHandle

//暂时没用
+ (void)uidWithAppKey:(NSString *)appKey accessToken:(NSString *)accessToken complateBlock:(DDSinaRequestBlock)completeBlock{
    if ([appKey length] == 0) {
        
        return;
    }
    if ([accessToken length] == 0) {
    
        return;
    }
    
    NSDictionary *dict = @{@"source":appKey,
                           @"access_token":accessToken};
    [self baseSendAsynchronousWithHostname:DDSinaHostName apiName:DDSinaAPINameUID params:dict completeHandle:^(NSDictionary *responseDict, NSError *connectionError) {
        if (completeBlock) {
            if (connectionError) {
                completeBlock(nil, connectionError);
            }
            else {
                completeBlock(responseDict, nil);
            }
        }
    }];
}

+ (void)userInfoWithAppKey:(NSString *)appKey accessToken:(NSString *)accessToken uid:(NSInteger )uid complateBlock:(DDSinaRequestBlock)completeBlock{
    if ([appKey length] == 0) {
        
        return;
    }
    if ([accessToken length] == 0) {
        
        return;
    }
    if (!uid) {
        
        return;
    }
    NSDictionary *dict = @{@"source":appKey,
                           @"access_token":accessToken,
                           @"uid":@(uid)};
    [self baseSendAsynchronousWithHostname:DDSinaHostName apiName:DDSinaAPINameUserInfo params:dict completeHandle:^(NSDictionary *responseDict, NSError *connectionError) {
        if (completeBlock) {
            if (connectionError) {
                completeBlock(nil, connectionError);
            }
            else {
                completeBlock(responseDict, nil);
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
                          completeHandle:(DDSinaRequestBlock)compleleHandle{
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
                if (connectionError) {
                    compleleHandle(nil,connectionError);
                }
                else {
                    NSInteger errorCode = [jsonDict[@"error_code"] integerValue];
                    if (errorCode) {
                        NSString *errorMessage = jsonDict[@"error"];
                        NSError *error = [NSError errorWithDomain:@"Sina Error" code:errorCode userInfo:@{@"description":errorMessage}];
                        compleleHandle(nil,error);
                    }
                    else {
                        compleleHandle(jsonDict,nil);
                    }
                }
            }
        }
    }];
}
@end
