//
//  DDUserInfoItem.h
//  DDSocialShareSDK
//
//  Created by lilingang on 15/8/12.
//  Copyright (c) 2015年 LeeLingang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DDGenderType) {
    DDGenderTypeUnkown,
    DDGenderTypeMale = 1,   //**男性*/
    DDGenderTypeFemale = 2, //**女性*/
};

@interface DDUserInfoItem : NSObject

//**用户昵称*/
@property (nonatomic, copy) NSString *nickName;
//**用户个人描述*/
@property (nonatomic, copy) NSString *desString;
//**性别*/
@property (nonatomic, assign) DDGenderType genderType;
//**用户头像地址*/
@property (nonatomic, copy) NSString *avatarURL;


- (instancetype)initWithMIUserInfoDict:(NSDictionary *)infoDict;

- (instancetype)initWithWeChatUserInfoDict:(NSDictionary *)infoDict;

- (instancetype)initWithSinaUserInfoDict:(NSDictionary *)infoDict;

- (instancetype)initWithTencentUserInfoDict:(NSDictionary *)infoDict;

@end
