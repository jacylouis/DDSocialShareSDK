//
//  DDSinaHandle.m
//  HMLoginDemo
//
//  Created by lilingang on 15/8/1.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDSinaHandle.h"
#import "WeiboSDK.h"

#import "DDSinaRequestHandle.h"

#import "DDAuthItem.h"
#import "DDUserInfoItem.h"

#import "UIImage+zoom.h"

/**授权回调页对移动客户端应用来说对用户是不可见的，所以定义为何种形式都将不影响，但是没有定义将无法使用SDK认证登录*/
NSString * const DDSinaRedirectURI = @"";

const CGFloat DDSinaThumbnailDataMaxSize = 32 * 1024.0;
const CGFloat DDSinaImageDataMaxSize = 5 * 1024 * 1024;

@interface DDSinaHandle ()<WeiboSDKDelegate>

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, strong) DDAuthItem *authItem;

@property (nonatomic, copy) DDAuthEventHandler authEventHandler;
@property (nonatomic, copy) DDShareContentEventHandler shareContentEventHandler;


@end

@implementation DDSinaHandle

+ (BOOL)isSinaInstalled{
    return [WeiboSDK isWeiboAppInstalled];
}

- (void)registerApp{
    [WeiboSDK registerApp:self.appKey];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (void)authCompleteHandle:(DDAuthEventHandler)completeHandle{
    self.authEventHandler = completeHandle;
    if (self.authEventHandler) {
        self.authEventHandler(DDSSAuthStateTypeBegan,nil,nil);
    }
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    request.redirectURI = DDSinaRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

- (void)getUserInfoCompleteHandle:(DDGetUserInfoEventHandler)completeHandle{
    [DDSinaRequestHandle userInfoWithAppKey:self.appKey accessToken:self.authItem.access_token uid:[self.authItem.uid integerValue] complateBlock:^(NSDictionary *responseDict, NSError *connectionError) {
        if (completeHandle) {
            if (connectionError) {
                completeHandle(nil,connectionError);
            }
            else {
                DDUserInfoItem *userInfoItem = [[DDUserInfoItem alloc] initWithSinaUserInfoDict:responseDict];
                completeHandle(userInfoItem,nil);
            }
        }
    }];
}

- (BOOL)shareWithProtocol:(id<DDShareSDKContentProtocol>)protocol
                     type:(DDSSShareType)shareType
           completeHandle:(DDShareContentEventHandler)completeHandle{
    self.shareContentEventHandler = completeHandle;
    if (self.shareContentEventHandler) {
        self.shareContentEventHandler(DDSSPlatformSina,DDSSShareSceneSina,DDSSStateTypeBegan,nil);
    }
    if (shareType == DDSSShareTypeText && [protocol conformsToProtocol:@protocol(DDShareSDKTextProtocol)]) {
        return [self shareTextWithProtocol:(id<DDShareSDKTextProtocol>)protocol completeHandle:completeHandle];
    }
    else if (shareType == DDSSShareTypeImage && [protocol conformsToProtocol:@protocol(DDShareSDKImageProtocol)]){
        return [self shareImageWithProtocol:(id<DDShareSDKImageProtocol>)protocol completeHandle:completeHandle];
    }
    else if (shareType == DDSSShareTypeWebPage && [protocol conformsToProtocol:@protocol(DDShareSDKWebPageProtocol)]){
        return [self shareWebPageWithProtocol:(id<DDShareSDKWebPageProtocol>)protocol completeHandle:completeHandle];
    }
    else {
        NSString *errorDescription = [NSString stringWithFormat:@"分享格式错误:%@ shareType:%lu",NSStringFromClass([protocol class]),(unsigned long)shareType];
        NSLog(@"%@",errorDescription);
        self.shareContentEventHandler = completeHandle;
        if (self.shareContentEventHandler) {
            NSError *error = [NSError errorWithDomain:@"format Error" code:1990 userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
            self.shareContentEventHandler(DDSSPlatformSina,DDSSShareSceneSina,DDSSStateTypeFail,error);
        }
        return NO;
    }
}

#pragma mark - Private Methods

#pragma mark - Share

- (BOOL)shareTextWithProtocol:(id<DDShareSDKTextProtocol>)protocol
               completeHandle:(DDShareContentEventHandler)completeHandle{
    WBMessageObject *message = [WBMessageObject message];
    message.text = [protocol ddShareText];
    return [self sendWithMessage:message];
}

- (BOOL)shareImageWithProtocol:(id<DDShareSDKImageProtocol>)protocol
                completeHandle:(DDShareContentEventHandler)completeHandle{
    WBImageObject *imageObject = [WBImageObject object];
    NSData *imageData = [protocol ddShareImageWithImageData];
    imageObject.imageData = [UIImage imageData:imageData maxBytes:DDSinaImageDataMaxSize];
    WBMessageObject *message = [WBMessageObject message];
    if ([protocol respondsToSelector:@selector(ddShareImageText)]) {
        message.text = [protocol ddShareImageText];
    }
    message.imageObject = imageObject;
    return [self sendWithMessage:message];
}

- (BOOL)shareWebPageWithProtocol:(id<DDShareSDKWebPageProtocol>)protocol
                  completeHandle:(DDShareContentEventHandler)completeHandle{
    BOOL useImage = NO;
    if ([protocol respondsToSelector:@selector(ddShareWebPageByImageWithShareScence:)]) {
        useImage = [protocol ddShareWebPageByImageWithShareScence:DDSSShareSceneSina];
    }
    WBMessageObject *message = [WBMessageObject message];
    if (useImage) {
        WBImageObject *imageObject = [WBImageObject object];
        NSData *imageData = [protocol ddShareWebPageWithImageData];
        imageObject.imageData = [UIImage imageData:imageData maxBytes:DDSinaImageDataMaxSize];
        NSString *shareText = @"";
        if ([protocol respondsToSelector:@selector(ddShareImageText)]) {
            NSString *text = [protocol ddShareWebPageText];
            if ([text length] && text) {
                shareText = [shareText stringByAppendingString:text];
            }
        }
        NSString *title = [protocol ddShareWebPageWithTitle];
        if ([title length] && title) {
            shareText = [shareText stringByAppendingString:title];
        }
        NSString *descriptionString = [protocol ddShareWebPageWithDescription];
        if ([descriptionString length] && descriptionString) {
            shareText = [shareText stringByAppendingString:descriptionString];
        }
        NSString *webpageUrl = [protocol ddShareWebPageWithWebpageUrl];
        if ([webpageUrl length] && webpageUrl) {
            shareText = [shareText stringByAppendingString:webpageUrl];
        }
        message.text = shareText;
        message.imageObject = imageObject;
    }
    else{
        WBWebpageObject *webPageObject = [WBWebpageObject object];
        webPageObject.objectID = [protocol ddShareWebPageWithObjectID];
        webPageObject.title = [protocol ddShareWebPageWithTitle];
        webPageObject.description = [protocol ddShareWebPageWithDescription];
        NSData *imageData = [protocol ddShareWebPageWithImageData];
        webPageObject.thumbnailData = [UIImage imageData:imageData maxBytes:DDSinaThumbnailDataMaxSize];
        webPageObject.webpageUrl = [protocol ddShareWebPageWithWebpageUrl];
        
        message.mediaObject = webPageObject;
        if ([protocol respondsToSelector:@selector(ddShareWebPageText)]) {
            message.text = [protocol ddShareWebPageText];
        }
    }
    return [self sendWithMessage:message];
}

- (BOOL)sendWithMessage:(WBMessageObject *)message{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = DDSinaRedirectURI;
    authRequest.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
    return [WeiboSDK sendRequest:request];
}


#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
 //没用吧 防止警告
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        //授权
        WeiboSDKResponseStatusCode statusCode = response.statusCode;
        switch (statusCode) {
            case WeiboSDKResponseStatusCodeSuccess: {
                WBAuthorizeResponse *authorizeResponse = (WBAuthorizeResponse *)response;
                self.authItem = [[DDAuthItem alloc] initWithSinaAuthDict:response.userInfo];
                self.authItem.expirationDate = authorizeResponse.expirationDate;
                if (self.authEventHandler) {
                    self.authEventHandler(DDSSAuthStateTypeSuccess,self.authItem,nil);
                    self.authEventHandler = nil;
                }
                break;
            }
            case WeiboSDKResponseStatusCodeUserCancel: {
                if (self.authEventHandler) {
                    self.authEventHandler(DDSSAuthStateTypeCancel,nil,nil);
                    self.authEventHandler = nil;
                }
                break;
            }
            case WeiboSDKResponseStatusCodeSentFail:
            case WeiboSDKResponseStatusCodeAuthDeny:
            case WeiboSDKResponseStatusCodeUnsupport:
            case WeiboSDKResponseStatusCodeUnknown: {
                if (self.authEventHandler) {
                    NSError *error = [NSError errorWithDomain:@"Sina Auth ERROR" code:statusCode userInfo:@{NSLocalizedDescriptionKey:@"授权失败"}];
                    self.authEventHandler(DDSSAuthStateTypeFail,nil,error);
                    self.authEventHandler = nil;
                }
                break;
            }
            default: {
                break;
            }
        }
    }
    else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]){
        WeiboSDKResponseStatusCode statusCode = response.statusCode;
        switch (statusCode) {
            case WeiboSDKResponseStatusCodeSuccess: {
                WBSendMessageToWeiboResponse *sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
                WBAuthorizeResponse *authorizeResponse = sendMessageToWeiboResponse.authResponse;
                if (authorizeResponse) {
                    self.authItem = [[DDAuthItem alloc] initWithSinaAuthDict:response.userInfo];
                    self.authItem.expirationDate = authorizeResponse.expirationDate;
                }
                if (self.shareContentEventHandler) {
                    self.shareContentEventHandler(DDSSPlatformSina,DDSSShareSceneSina,DDSSStateTypeSuccess,nil);
                    self.shareContentEventHandler = nil;
                }
                break;
            }
            case WeiboSDKResponseStatusCodeUserCancel: {
                if (self.shareContentEventHandler) {
                    self.shareContentEventHandler(DDSSPlatformSina,DDSSShareSceneSina,DDSSStateTypeCancel,nil);
                    self.shareContentEventHandler = nil;
                }
                break;
            }
            case WeiboSDKResponseStatusCodeSentFail:
            case WeiboSDKResponseStatusCodeAuthDeny:
            case WeiboSDKResponseStatusCodeUnsupport:
            case WeiboSDKResponseStatusCodeUnknown: {
                if (self.shareContentEventHandler) {
                    NSError *error = [NSError errorWithDomain:@"Sina Share ERROR" code:statusCode userInfo:@{NSLocalizedDescriptionKey:@"分享失败"}];
                    if (self.shareContentEventHandler) {
                        self.shareContentEventHandler(DDSSPlatformSina,DDSSShareSceneSina,DDSSStateTypeFail,error);
                        self.shareContentEventHandler = nil;
                    }
                }
                break;
            }
            default: {
                break;
            }
        }
    }
}


#pragma mark - Getter and Setter
- (NSString *)appKey{
    if (!_appKey) {
        NSArray *urlTypesArray = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
        NSArray *urlSchemes;
        for (NSDictionary *dict in urlTypesArray) {
            if ([[dict objectForKey:@"CFBundleURLName"] isEqualToString:@"com.weibo"]) {
                urlSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
                break;
            }
        }
        if ([urlSchemes count] == 0) {
            _appKey = @"none error";
        }
        _appKey = [urlSchemes firstObject];
        _appKey = [_appKey stringByReplacingOccurrencesOfString:@"wb" withString:@""];
    }
    return _appKey;
}
@end
