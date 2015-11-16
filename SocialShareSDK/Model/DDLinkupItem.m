//
//  DDLinkupItem.m
//  midong
//
//  Created by lilingang on 15/8/26.
//  Copyright (c) 2015年 HM IOS Team. All rights reserved.
//

#import "DDLinkupItem.h"

@implementation DDLinkupItem

+ (DDLinkupItem *)linkupItemWithUserName:(NSString *)userName
                                  extMsg:(NSString *)extMsg
                                    type:(DDLinkupType)type{
    DDLinkupItem *item = [[DDLinkupItem alloc] init];
    item.username = userName;
    item.extMsg = extMsg;
    item.linkupType = type;
    return item;
}

@end
