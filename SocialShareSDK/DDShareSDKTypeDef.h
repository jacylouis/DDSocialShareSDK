//
//  DDShareSDKTypeDef.h
//  HMLoginDemo
//
//  Created by lilingang on 15/7/31.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#ifndef HMLoginDemo_DDShareSDKTypeDef_h
#define HMLoginDemo_DDShareSDKTypeDef_h

#ifndef _
#define _MI(s,comment) NSLocalizedStringFromTable(s,@"DDMILocalizable",comment)
#endif

/**define the third party platform*/
typedef NS_ENUM(NSUInteger, DDSSPlatform) {
    DDSSPlatformNone = 0,
    DDSSPlatformMI,       //**小米 */
    DDSSPlatformWeChat,   //**微信 */
    DDSSPlatformQQ,       //**QQ客户端*/
    DDSSPlatformSina,     //**新浪微博*/
};

/**define the third party sharing scene*/
typedef NS_ENUM(NSUInteger, DDSSShareScene) {
    DDSSShareSceneWXSession,     /**< 聊天界面    */
    DDSSShareSceneWXTimeline,    /**< 朋友圈      */
    DDSSShareSceneQQFrined,      /**< QQ好友      */
    DDSSShareSceneQZone,         /**< QQ空间      */
    DDSSShareSceneSina,          /**< 新浪微博     */
};

/**
 *  @brief  第三方分享类型
 */
typedef NS_ENUM(NSUInteger, DDSSShareType) {
    DDSSShareTypeText,        /**< 纯文本分享 */
    DDSSShareTypeImage,       /**< 图片分享 */
    DDSSShareTypeWebPage,     /**< 网页分享 */
};

/**
 *	@brief	获取需要授权的临时code状态
 */
typedef NS_ENUM(NSUInteger, DDSSAuthCodeStateType) {
    DDSSAuthCodeStateTypeBegan = 0,   /**< 开始 */
    DDSSAuthCodeStateTypeSuccess = 1, /**< 成功 */
    DDSSAuthCodeStateTypeFail = 2,    /**< 失败 */
    DDSSAuthCodeStateTypeCancel = 3   /**< 取消 */
};

/**
 *	@brief	授权状态
 */
typedef NS_ENUM(NSUInteger, DDSSAuthStateType) {
    DDSSAuthStateTypeBegan = 0,   /**< 开始 */
    DDSSAuthStateTypeSuccess = 1, /**< 成功 */
    DDSSAuthStateTypeFail = 2,    /**< 失败 */
    DDSSAuthStateTypeCancel = 3   /**< 取消 */
};

/**
 *	@brief	第三方分享状态
 */
typedef NS_ENUM(NSUInteger, DDSSStateType) {
    DDSSStateTypeBegan = 0,   /**< 开始 */
    DDSSStateTypeSuccess = 1, /**< 成功 */
    DDSSStateTypeFail = 2,    /**< 失败 */
    DDSSStateTypeCancel = 3   /**< 取消 */
};

#endif
