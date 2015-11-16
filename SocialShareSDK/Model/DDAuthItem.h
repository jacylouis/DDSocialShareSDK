//
//  DDAuthItem.h
//  DDSocialShareSDK
//
//  Created by lilingang on 15/8/12.
//  Copyright (c) 2015年 LeeLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TencentOAuth;

@interface DDAuthItem : NSObject

/**
 *接口调用凭证
 *@note 第三方授权都会有改属性
 */
@property (nonatomic, copy) NSString *access_token;

/**
 *用户ID
 *@warning 新浪/腾讯/微信 有该参数
 */
@property (nonatomic, strong) NSString *uid;

/**
 *access_token接口调用凭证超时时间，单位（秒）
 *@warning 新浪/微信/小米 有该参数
 */
@property (nonatomic, assign) NSInteger expires_in;

/**
 *认证过期时间
 *@warning 新浪/腾讯 有该参数
 */
@property (nonatomic, strong) NSDate *expirationDate;

/**
 *当认证口令过期时用于换取认证口令的更新口令
 *@warning 新浪/微信  有该参数
 */
@property (nonatomic, strong) NSString *refresh_token;


/**
 *用户授权的作用域，使用逗号（,）分隔
 *@warning 小米/微信  有该参数
 */
@property (nonatomic, copy) NSString *scope;

/**********微信**********/
/**
 *只有在用户将公众号绑定到微信开放平台帐号后，才会出现该字段。
 *@warning 微信 有该参数
 */
@property (nonatomic, copy) NSString *unionid;

/*********腾讯***********/
/** 
 *第三方应用在开发过程中设置的URLSchema，用于浏览器登录后后跳到第三方应用 
 *@warning 腾讯 有该参数
 */
@property(nonatomic, copy) NSString* localAppId;

/*********小米***********/
/**
 *如果请求时传递参数，会回传该参数
 *@warning 小米 有该参数
 */
@property (nonatomic, copy) NSString *state;
/**
 *说明返回的token类型,目前是mac
 *@warning 小米 有该参数
 */
@property (nonatomic, copy) NSString *token_type;
/**
 *mac密钥
 *@warning 小米 有该参数
 */
@property (nonatomic, copy) NSString *mac_key;
/**
 *mac计算的算法名称
 *@warning 小米 有该参数
 */
@property (nonatomic, copy) NSString *mac_algorithm;

- (instancetype)initWithTencentOAuth:(TencentOAuth *)tencentOAuth;

- (instancetype)initWithMIAuthDict:(NSDictionary *)authDict;

- (instancetype)initWithWeChatAuthDict:(NSDictionary *)authDict;

- (instancetype)initWithSinaAuthDict:(NSDictionary *)authDict;

@end
