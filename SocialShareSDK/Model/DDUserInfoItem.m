//
//  DDUserInfoItem.m
//  DDSocialShareSDK
//
//  Created by lilingang on 15/8/12.
//  Copyright (c) 2015年 LeeLingang. All rights reserved.
//

#import "DDUserInfoItem.h"

@implementation DDUserInfoItem

- (instancetype)initWithMIUserInfoDict:(NSDictionary *)infoDict{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithWeChatUserInfoDict:(NSDictionary *)infoDict{
    self = [super init];
    if (self) {
        self.nickName = [infoDict objectForKey:@"nickname"];
        NSInteger sex = [[infoDict objectForKey:@"sex"] integerValue];
        if (sex == 1) {
            self.genderType = DDGenderTypeMale;
        }
        else {
            self.genderType = DDGenderTypeFemale;
        }
        self.avatarURL = [infoDict objectForKey:@"headimgurl"];
    }
    return self;
}

- (instancetype)initWithSinaUserInfoDict:(NSDictionary *)infoDict{
    self = [super init];
    if (self) {
        self.nickName = [infoDict objectForKey:@"screen_name"];
        self.desString = [infoDict objectForKey:@"description"];
        NSString *genderString = [infoDict objectForKey:@"gender"];
        if ([genderString isEqualToString:@"m"]) {
            self.genderType = DDGenderTypeMale;
        } else if ([genderString isEqualToString:@"f"]){
            self.genderType = DDGenderTypeFemale;
        } else {
            self.genderType = DDGenderTypeUnkown;
        }
        
        self.avatarURL = [infoDict objectForKey:@"avatar_large"];
        if ([infoDict objectForKey:@"avatar_hd"]) {
            self.avatarURL = [infoDict objectForKey:@"avatar_hd"];
        }
    }
    return self;
}

- (instancetype)initWithTencentUserInfoDict:(NSDictionary *)infoDict{
    self = [super init];
    if (self) {
        self.nickName = [infoDict objectForKey:@"nickname"];
        NSString *genderString = [infoDict objectForKey:@"gender"];
        self.genderType = DDGenderTypeMale;
        if ([genderString isEqualToString:@"女"]) {
            self.genderType = DDGenderTypeFemale;
        }

        /**大小为100×100像素的QQ头像URL。需要注意，不是所有的用户都拥有QQ的100x100 figureurl_qq_2的头像，但figureurl_qq_1 40x40像素则是一定会有*/
        self.avatarURL = [infoDict objectForKey:@"figureurl_qq_1"];
        if ([infoDict objectForKey:@"figureurl_qq_2"]) {
            self.avatarURL = [infoDict objectForKey:@"figureurl_qq_2"];
        }
    }
    return self;
}
@end
