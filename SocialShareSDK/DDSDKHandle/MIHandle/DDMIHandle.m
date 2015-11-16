//
//  DDMIHandle.m
//  HMLoginDemo
//
//  Created by lilingang on 15/8/3.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDMIHandle.h"

#import "DDMILoginViewController.h"
#import "DDMIVerifyLoginViewController.h"
#import "DDMIAuthViewController.h"

#import "DDMIRequestHandle.h"

#import "DDAuthItem.h"

NSString * const DDMIRedirectURI = @"http://xiaomi.com";

@interface DDMIHandle ()<DDMICancelDelegate,DDMILoginViewControllerDelegate,DDMIAuthViewControllerDelegate,DDMIVerifyLoginViewControllerDelegate>

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, strong) DDAuthItem *authItem;

@property (nonatomic, strong) UINavigationController *navigationController;

@property (nonatomic, strong) DDMIRequestHandle *requestHandle;

@property (nonatomic, copy) DDAuthCodeEventHandler authCodeEventHandle;

@property (nonatomic, copy) DDAuthEventHandler authEventHandle;

@property (nonatomic, assign) DDMIAuthResponseType  responseType;

@end

@implementation DDMIHandle

- (void)getAuthCodeWithController:(UIViewController *)viewController
                   completeHandle:(DDAuthCodeEventHandler)completeHandle{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.responseType = DDMIAuthResponseTypeCode;
    self.authCodeEventHandle = completeHandle;
    if (self.authCodeEventHandle) {
        self.authCodeEventHandle(DDSSAuthCodeStateTypeBegan,nil,nil);
    }
    [self presetLoginViewControllerInViewController:viewController];
}

- (void)authWithController:(UIViewController *)viewController
            completeHandle:(DDAuthEventHandler)completeHandle{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.responseType = DDMIAuthResponseTypeToken;
    self.authEventHandle = completeHandle;
    if (self.authEventHandle) {
        self.authEventHandle(DDSSAuthStateTypeBegan,nil,nil);
    }
    [self presetLoginViewControllerInViewController:viewController];
}

- (void)getUserInfoCompleteHandle:(DDGetUserInfoEventHandler)completeHandle{
    //暂时未实现
//    [self.requestHandle userInfoWithAppID:self.appKey
//                              accessToken:self.authItem.access_token
//                                   mackey:self.authItem.mac_key
//                           compleleHandle:^(NSDictionary *responseDict, NSError *connectionError) {
//        if (completeHandle) {
//            completeHandle(nil,connectionError);
//        }
//    }];
}

#pragma mark - Private Methods

- (void)presetLoginViewControllerInViewController:(UIViewController *)viewController{
    DDMILoginViewController *loginViewController = [[DDMILoginViewController alloc] initWithRequestHandle:self.requestHandle];
    loginViewController.delegate = self;
    loginViewController.cancelDelegate = self;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [viewController presentViewController:self.navigationController animated:YES completion:nil];
}

- (void)pushWebAuthViewContoller{
    DDMIAuthViewController *viewController = [[DDMIAuthViewController alloc] initWithAppid:self.appKey redirectUrl:DDMIRedirectURI];
    viewController.cancelDelegate = self;
    viewController.delegate = self;
    viewController.responseType = self.responseType;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pushVerifyLoginViewControllerWithAccount:(NSString *)account{
    DDMIVerifyLoginViewController *viewController = [[DDMIVerifyLoginViewController alloc] initWithRequestHandle:self.requestHandle];
    viewController.delegate = self;
    viewController.cancelDelegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)disMissWithCompletion:(void (^)(void))completion{
    __weak __typeof(&*self)weakSelf = self;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        weakSelf.navigationController = nil;
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - DDMICancelDelegate

- (void)viewControllerCanceled:(UIViewController *)viewController{
    __weak __typeof(&*self)weakSelf = self;
    [self disMissWithCompletion:^{
        if (weakSelf.authCodeEventHandle) {
            weakSelf.authCodeEventHandle(DDSSAuthCodeStateTypeCancel,nil,nil);
            weakSelf.authCodeEventHandle = nil;
        }
        if (weakSelf.authEventHandle) {
            weakSelf.authEventHandle(DDSSAuthStateTypeCancel,nil,nil);
            weakSelf.authEventHandle = nil;
        }
    }];
}

#pragma mark - DDMILoginViewControllerDelegate

- (void)loginViewController:(DDMILoginViewController *)viewController successNeedDaynamicCode:(BOOL)needDaynamicCode{
    if (!needDaynamicCode) {
        [self pushWebAuthViewContoller];
    }
    else {
        [self pushVerifyLoginViewControllerWithAccount:self.requestHandle.account];
    }
}

#pragma mark - DDMIVerifyLoginViewControllerDelegate

- (void)viewControllerDidVerifySucess:(DDMIVerifyLoginViewController *)viewController{
    [self pushWebAuthViewContoller];
}

- (void)viewControllerNeedPop:(DDMIVerifyLoginViewController *)viewController{
    [self.navigationController popViewControllerAnimated:YES];
    self.requestHandle.delegate = ((DDMILoginViewController *)self.navigationController.topViewController);
}

#pragma mark - DDMIAuthViewControllerDelegate

- (void)authViewController:(DDMIAuthViewController *)viewController failedWithError:(NSError *)error{
    __weak __typeof(&*self)weakSelf = self;
    [self disMissWithCompletion:^{
        if (weakSelf.responseType == DDMIAuthResponseTypeCode) {
            if (weakSelf.authCodeEventHandle) {
                weakSelf.authCodeEventHandle(DDSSAuthCodeStateTypeFail,nil,error);
                weakSelf.authCodeEventHandle = nil;
            }
        }
        else {
            if (weakSelf.authEventHandle) {
                weakSelf.authEventHandle(DDSSAuthStateTypeFail,nil,error);
                weakSelf.authEventHandle = nil;
            }
        }
    }];
}

- (void)authViewController:(DDMIAuthViewController *)viewController successWithResponse:(NSDictionary *)response{
    __weak __typeof(&*self)weakSelf = self;
    [self disMissWithCompletion:^{
        if (weakSelf.responseType == DDMIAuthResponseTypeCode) {
            if (weakSelf.authCodeEventHandle) {
                weakSelf.authCodeEventHandle(DDSSAuthCodeStateTypeSuccess,[response objectForKey:@"code"],nil);
            }
        }
        else {
            weakSelf.authItem = [[DDAuthItem alloc] initWithMIAuthDict:response];
            if (weakSelf.authEventHandle) {
                weakSelf.authEventHandle(DDSSAuthStateTypeSuccess,weakSelf.authItem,nil);
                weakSelf.authEventHandle = nil;
            }
        }
    }];
}

- (void)authViewControllerSwitchLogin{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Getter and Setter

- (DDMIRequestHandle *)requestHandle{
    if (!_requestHandle) {
        _requestHandle = [[DDMIRequestHandle alloc] init];
    }
    return _requestHandle;
}

- (NSString *)appKey{
    if (!_appKey) {
        NSArray *urlTypesArray = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
        NSArray *urlSchemes;
        for (NSDictionary *dict in urlTypesArray) {
            if ([[dict objectForKey:@"CFBundleURLName"] isEqualToString:@"xiaomi"]) {
                urlSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
                break;
            }
        }
        if ([urlSchemes count] == 0) {
            _appKey = @"none error";
        }
        _appKey = [urlSchemes firstObject];
        _appKey = [_appKey stringByReplacingOccurrencesOfString:@"mi" withString:@""];
    }
    return _appKey;
}

@end
