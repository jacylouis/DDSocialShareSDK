//
//  DDMIAuthViewController.h
//  HMLoginDemo
//
//  Created by lilingang on 15/8/4.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDMIBaseViewController.h"

typedef NS_ENUM(NSUInteger, DDMIAuthResponseType) {
    DDMIAuthResponseTypeCode, //Authorization Code Flow
    DDMIAuthResponseTypeToken, //Implicit Flow
};

@class DDMIAuthViewController;

@protocol DDMIAuthViewControllerDelegate <NSObject>

- (void)authViewController:(DDMIAuthViewController *)viewController successWithResponse:(NSDictionary *)response;
- (void)authViewController:(DDMIAuthViewController *)viewController failedWithError:(NSError *)error;
- (void)authViewControllerSwitchLogin;

@end

@interface DDMIAuthViewController : DDMIBaseViewController

@property (nonatomic, weak) id<DDMIAuthViewControllerDelegate> delegate;

@property (nonatomic, assign) DDMIAuthResponseType  responseType;

- (instancetype)initWithAppid:(NSString *)appID redirectUrl:(NSString *)redirectUrl;

@end
