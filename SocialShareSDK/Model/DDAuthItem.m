//
//  DDAuthItem.m
//  DDSocialShareSDK
//
//  Created by lilingang on 15/8/12.
//  Copyright (c) 2015年 LeeLingang. All rights reserved.
//

#import "DDAuthItem.h"

#import <TencentOpenAPI/TencentOAuth.h>

@interface DDAuthItem ()

@end


@implementation DDAuthItem

- (instancetype)initWithTencentOAuth:(TencentOAuth *)tencentOAuth{
    self = [super init];
    if (self) {
        self.access_token = tencentOAuth.accessToken;
        self.expirationDate = tencentOAuth.expirationDate;
        self.localAppId = tencentOAuth.localAppId;
        self.uid = tencentOAuth.openId;
    }
    return self;
}

- (instancetype)initWithMIAuthDict:(NSDictionary *)authDict{
    self = [super init];
    if (self) {
        self.access_token = [authDict objectForKey:@"access_token"];
        self.expires_in = [[authDict objectForKey:@"expires_in"] integerValue];
        self.scope = [authDict objectForKey:@"scope"];
        self.state = [authDict objectForKey:@"state"];
        self.token_type = [authDict objectForKey:@"token_type"];
        self.mac_key = [authDict objectForKey:@"mac_key"];
        self.mac_algorithm = [authDict objectForKey:@"mac_algorithm"];

    }
    return self;
}

- (instancetype)initWithWeChatAuthDict:(NSDictionary *)authDict{
    self = [super init];
    if (self) {
        self.access_token = [authDict objectForKey:@"access_token"];
        self.expires_in = [[authDict objectForKey:@"expires_in"] integerValue];
        self.refresh_token = [authDict objectForKey:@"refresh_token"];
        self.uid = [authDict objectForKey:@"openid"];
        self.scope = [authDict objectForKey:@"scope"];
        self.unionid = [authDict objectForKey:@"unionid"];
    }
    return self;
}

- (instancetype)initWithSinaAuthDict:(NSDictionary *)authDict{
    self = [super init];
    if (self) {
        self.uid = [authDict objectForKey:@"uid"];
        self.access_token = [authDict objectForKey:@"access_token"];
        self.expires_in = [[authDict objectForKey:@"expires_in"] integerValue];
        self.refresh_token = [authDict objectForKey:@"refresh_token"];
    }
    return self;
}

@end


