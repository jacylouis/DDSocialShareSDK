//
//  DDSinaRequestHandle.h
//  HMLoginDemo
//
//  Created by lilingang on 15/8/2.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DDSinaRequestBlock) (NSDictionary *responseDict, NSError *connectionError);

@interface DDSinaRequestHandle : NSObject

+ (void)userInfoWithAppKey:(NSString *)appKey accessToken:(NSString *)accessToken uid:(NSInteger )uid complateBlock:(DDSinaRequestBlock)completeBlock;

@end
