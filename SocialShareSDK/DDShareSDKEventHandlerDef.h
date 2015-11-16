//
//  DDShareSDKEventHandlerDef.h
//  HMLoginDemo
//
//  Created by lilingang on 15/7/31.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDShareSDKTypeDef.h"

@class DDAuthItem;
@class DDUserInfoItem;

#ifndef HMLoginDemo_DDShareSDKEventHandlerDef_h
#define HMLoginDemo_DDShareSDKEventHandlerDef_h

/**
 *  授权之前获取的code
 *
 *  @param state    获取授权code的状态
 *  @param code     返回的授权码
 *  @param error    错误信息,仅当state为SSAuthStateFail时有效
 */
typedef void(^DDAuthCodeEventHandler) (DDSSAuthCodeStateType state,NSString *code, NSError *error);

/**
 *	@brief	授权事件处理器
 *
 *  @param  state    授权状态
 *  @param  authInfo 授权信息
 *  @param  error    授权失败的错误信息,仅当state为SSAuthStateFail时有效
 */
typedef void(^DDAuthEventHandler) (DDSSAuthStateType state,DDAuthItem *authItem, NSError *error);


/**
 *	@brief	获取用户信息事件处理器
 *
 *  @param  result  回复标识，YES：获取成功，NO：获取失败
 *  @param  userInfo     用户信息
 *  @param  error   获取失败的错误信息
 */
typedef void(^DDGetUserInfoEventHandler) (DDUserInfoItem *userInfoItem, NSError *error);

/**
 *	@brief	分享内容事件处理器
 *
 *  @param type       平台类型
 *  @param shareScene 分享场景
 *  @param state      分享状态
 *  @param error      分享失败错误信息
 */
typedef void(^DDShareContentEventHandler) (DDSSPlatform type, DDSSShareScene shareScene, DDSSStateType state, NSError *error);

#endif
