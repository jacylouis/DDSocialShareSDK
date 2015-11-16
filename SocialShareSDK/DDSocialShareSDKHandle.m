//
//  DDSocialShareSDKHandle.m
//  DDSocialShareSDK
//
//  Created by lilingang on 15/8/12.
//  Copyright (c) 2015年 LeeLingang. All rights reserved.
//

#import "DDSocialShareSDKHandle.h"

#import "DDMIHandle.h"
#import "DDWeChatHandle.h"
#import "DDTencentHandle.h"
#import "DDSinaHandle.h"

@interface DDSocialShareSDKHandle ()

@property (nonatomic, strong) DDMIHandle *miHandle;

@property (nonatomic, strong) DDWeChatHandle *wechatHandle;

@property (nonatomic, strong) DDTencentHandle *tencentHandle;

@property (nonatomic, strong) DDSinaHandle *sinaHandle;

@end

@implementation DDSocialShareSDKHandle


#pragma mark - Life Cycle
+ (DDSocialShareSDKHandle *)sharedInstance{
    static DDSocialShareSDKHandle *_instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)clear{
    self.miHandle = nil;
    self.wechatHandle = nil;
    self.tencentHandle = nil;
    self.sinaHandle = nil;
}

#pragma mark - Public Methods

+ (BOOL)isInstalledPlatform:(DDSSPlatform)platform{
    BOOL installed = NO;
    if (platform == DDSSPlatformWeChat) {
        installed = [DDWeChatHandle isWeChatInstalled];
    }
    else if (platform == DDSSPlatformQQ){
        installed = [DDTencentHandle isQQInstalled];
    }
    else if (platform == DDSSPlatformSina){
        installed = [DDSinaHandle isSinaInstalled];
    }
    return installed;
}

+ (NSString *)appkeyWithPlatform:(DDSSPlatform)platform{
    DDSocialShareSDKHandle *handle = [DDSocialShareSDKHandle sharedInstance];
    switch (platform) {
        case DDSSPlatformMI: {
            return  handle.miHandle.appKey;
            break;
        }
        case DDSSPlatformWeChat: {
            return handle.wechatHandle.appKey;
            break;
        }
        case DDSSPlatformQQ: {
            return handle.tencentHandle.appKey;
            break;
        }
        case DDSSPlatformSina: {
            return handle.sinaHandle.appKey;
            break;
        }
        default: {
            return nil;
            break;
        }
    }
}

- (void)registerPlatform:(DDSSPlatform)platform{
    if (platform == DDSSPlatformWeChat) {
        [self.wechatHandle registerApp];
    }
    if (platform == DDSSPlatformSina) {
        [self.sinaHandle registerApp];
    }
}

- (BOOL)handleOpenURL:(NSURL *)url{
    BOOL canWeChatOpen = [self.wechatHandle handleOpenURL:url];
    BOOL canTencentOpen = [self.tencentHandle handleOpenURL:url];
    BOOL canSinaOpen = [self.sinaHandle handleOpenURL:url];
    return canWeChatOpen || canTencentOpen || canSinaOpen;
}

- (void)getAuthCodeWithPlatform:(DDSSPlatform)platform
                     controller:(UIViewController *)viewController
                 compleleHandle:(DDAuthCodeEventHandler)complateHandle{
    if (platform == DDSSPlatformMI) {
        [self.miHandle getAuthCodeWithController:viewController completeHandle:complateHandle];
    }
    else if (platform == DDSSPlatformWeChat) {
        [self.wechatHandle getAuthCodeWithController:viewController completeHandle:complateHandle];
    }
}

- (void)authWithPlatform:(DDSSPlatform)platform
              controller:(UIViewController *)viewController
          compleleHandle:(DDAuthEventHandler)complateHandle{
    if (platform == DDSSPlatformMI) {
        [self.miHandle authWithController:viewController completeHandle:complateHandle];
    }
    else if (platform == DDSSPlatformWeChat) {
        [self.wechatHandle authWithController:viewController completeHandle:complateHandle];
    }
    else if (platform == DDSSPlatformQQ){
        [self.tencentHandle authCompleteHandle:complateHandle];
    }
    else if (platform == DDSSPlatformSina){
        [self.sinaHandle authCompleteHandle:complateHandle];
    }
}

- (void)getUserInfoWithPlatform:(DDSSPlatform)platform
                 compleleHandle:(DDGetUserInfoEventHandler)compleleHandle{
    if (platform == DDSSPlatformMI) {
        [self.miHandle getUserInfoCompleteHandle:compleleHandle];
    }
    else if (platform == DDSSPlatformWeChat) {
        [self.wechatHandle getUserInfoCompleteHandle:compleleHandle];
    }
    else if(platform == DDSSPlatformQQ){
        [self.tencentHandle getUserInfoCompleteHandle:compleleHandle];
    }
    else if(platform == DDSSPlatformSina){
        [self.sinaHandle getUserInfoCompleteHandle:compleleHandle];
    }
}

- (BOOL)shareWithPlatform:(DDSSPlatform)platform
               shareScene:(DDSSShareScene)shareScene
                shareType:(DDSSShareType)shareType
                 protocol:(id<DDShareSDKContentProtocol>)protocol
           completeHandle:(DDShareContentEventHandler)completeHandle{
    if (![self respondsToSelectorWithProtocol:protocol type:shareType]) {
        return NO;
    }
    if (platform == DDSSPlatformWeChat) {
        return [self.wechatHandle shareWithProtocol:protocol scene:shareScene type:shareType completeHandle:completeHandle];
    }
    else if (platform == DDSSPlatformQQ){
        return [self.tencentHandle shareWithProtocol:protocol scene:shareScene type:shareType completeHandle:completeHandle];
    }
    else if (platform == DDSSPlatformSina){
        return [self.sinaHandle shareWithProtocol:protocol type:shareType completeHandle:completeHandle];
    }
    else {
        NSLog(@"暂未支持的平台:%lu",(unsigned long)platform);
        return NO;
    }
}

- (BOOL)linkupWithPlatform:(DDSSPlatform)platform
                      item:(DDLinkupItem *)linkupItem{
    if (platform == DDSSPlatformWeChat) {
        return [self.wechatHandle linkupWithItem:linkupItem];
    }
    else if (platform == DDSSPlatformQQ){
        //未实现
    }
    return NO;
}

#pragma mark - Private Methods

- (BOOL)respondsToSelectorWithProtocol:(id<DDShareSDKContentProtocol>)protocol type:(DDSSShareType)shareType{
    if (shareType == DDSSShareTypeText) {
        return [self respondsToSelectorWithTextProtocol:(id<DDShareSDKTextProtocol>)protocol];
    }
    else if (shareType == DDSSShareTypeImage){
        return [self respondsToSelectorWithImageProtocol:(id<DDShareSDKImageProtocol>)protocol];
    }
    else if (shareType == DDSSShareTypeWebPage){
        return [self respondsToSelectorWithWebPageProtocol:(id<DDShareSDKWebPageProtocol>)protocol];
    }
    else {
        return NO;
    }
}

- (BOOL)respondsToSelectorWithTextProtocol:(id<DDShareSDKTextProtocol>)protocol{
    return [self protocol:protocol respondsToSelector:@selector(ddShareText)];
}

- (BOOL)respondsToSelectorWithImageProtocol:(id<DDShareSDKImageProtocol>)protocol{
    [self protocol:protocol respondsToSelector:@selector(ddShareImageWithImageData)];
    [self protocol:protocol respondsToSelector:@selector(ddShareImageWithTitle)];
    [self protocol:protocol respondsToSelector:@selector(ddShareImageWithDescription)];
    [self protocol:protocol respondsToSelector:@selector(ddShareImageWithWebpageUrl)];
    return YES;
}

- (BOOL)respondsToSelectorWithWebPageProtocol:(id<DDShareSDKWebPageProtocol>)protocol{
    [self protocol:protocol respondsToSelector:@selector(ddShareWebPageWithTitle)];
    [self protocol:protocol respondsToSelector:@selector(ddShareWebPageWithDescription)];
    [self protocol:protocol respondsToSelector:@selector(ddShareWebPageWithImageData)];
    [self protocol:protocol respondsToSelector:@selector(ddShareWebPageWithWebpageUrl)];
    [self protocol:protocol respondsToSelector:@selector(ddShareWebPageWithObjectID)];
    return YES;
}

- (BOOL)protocol:(id)protocol respondsToSelector:(SEL)selector{
    if (![protocol respondsToSelector:selector]) {
        NSString *assetString = [NSString stringWithFormat:@"%@ not implementation method %@ ",NSStringFromProtocol(protocol),NSStringFromSelector(selector)];
        NSAssert(NO,assetString);
    }
    return YES;
}

#pragma mark - Getter and Setter

- (DDMIHandle *)miHandle{
    if (!_miHandle) {
        _miHandle = [[DDMIHandle alloc] init];
    }
    return _miHandle;
}

- (DDWeChatHandle *)wechatHandle {
    if (!_wechatHandle) {
        _wechatHandle = [[DDWeChatHandle alloc] init];
    }
    return _wechatHandle;
}

- (DDTencentHandle *)tencentHandle{
    if (!_tencentHandle) {
        _tencentHandle = [[DDTencentHandle alloc] init];
    }
    return _tencentHandle;
}

- (DDSinaHandle *)sinaHandle{
    if (!_sinaHandle) {
        _sinaHandle = [[DDSinaHandle alloc] init];
    }
    return _sinaHandle;
}

@end
