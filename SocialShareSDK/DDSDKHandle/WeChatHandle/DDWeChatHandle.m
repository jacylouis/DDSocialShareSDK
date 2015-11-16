//
//  DDWeChatHandle.m
//  HMLoginDemo
//
//  Created by lilingang on 15/7/31.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDWeChatHandle.h"
#import "WXApi.h"

//Request
#import "DDWeChatRequestHandle.h"

//Model
#import "DDAuthItem.h"
#import "DDUserInfoItem.h"
#import "DDLinkupItem.h"

#import "UIImage+zoom.h"


NSString * const DDWeChatAppSecret = @"";

const CGFloat DDWeChatThumbnailDataMaxSize = 32 * 1024.0;
const CGFloat DDWeChatImageDataMaxSize = 10 * 1024.0 * 1024.0;

@interface DDWeChatHandle ()<WXApiDelegate>

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, strong) DDAuthItem *authItem;

@property (nonatomic, copy) DDAuthCodeEventHandler authCodeHandle;
@property (nonatomic, copy) DDAuthEventHandler authEventHandler;
@property (nonatomic, copy) DDGetUserInfoEventHandler userInfoEventHandler;
@property (nonatomic, copy) DDShareContentEventHandler shareContentEventHandler;
@property (nonatomic, assign) DDSSShareScene shareScene;

@end

@implementation DDWeChatHandle

+ (BOOL)isWeChatInstalled{
    return [WXApi isWXAppInstalled];
}

- (void)registerApp{
    [WXApi registerApp:self.appKey withDescription:@""];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)getAuthCodeWithController:(UIViewController *)viewController
                   completeHandle:(DDAuthCodeEventHandler)completeHandle{
    self.authCodeHandle = completeHandle;
    if (self.authCodeHandle) {
        self.authCodeHandle(DDSSAuthCodeStateTypeBegan,nil,nil);
    }
    SendAuthReq* authReq =[[SendAuthReq alloc ] init ];
    authReq.scope = @"snsapi_userinfo" ;
    authReq.state = @"1990" ;
    [WXApi sendAuthReq:authReq viewController:viewController delegate:self];
}

- (void)authWithController:(UIViewController *)viewController completeHandle:(DDAuthEventHandler)completeHandle{
    self.authEventHandler = completeHandle;
    if (self.authEventHandler) {
        self.authEventHandler(DDSSAuthStateTypeBegan,nil,nil);
    }
    __weak __typeof(&*self)weakSelf = self;
    [self getAuthCodeWithController:viewController completeHandle:^(DDSSAuthCodeStateType state, NSString *code, NSError *error) {
        if (weakSelf.authEventHandler) {
            switch (state) {
                case DDSSAuthCodeStateTypeSuccess: {
                    [weakSelf getTokenInfoWithAuthCode:code];
                    break;
                }
                case DDSSAuthCodeStateTypeFail: {
                    weakSelf.authEventHandler(DDSSAuthStateTypeFail,nil,error);
                    weakSelf.authEventHandler = nil;
                    break;
                }
                case DDSSAuthCodeStateTypeCancel: {
                    weakSelf.authEventHandler(DDSSAuthStateTypeCancel,nil,nil);
                    weakSelf.authEventHandler = nil;
                    break;
                }
                default: {
                    break;
                }
            }
        }
    }];
}

- (void)getUserInfoCompleteHandle:(DDGetUserInfoEventHandler)completeHandle{
    self.userInfoEventHandler = completeHandle;
    __weak __typeof(&*self)weakSelf = self;
    [DDWeChatRequestHandle userInfoWithToken:self.authItem.access_token openid:self.authItem.uid compleleHandle:^(NSDictionary *responseDict, NSError *connectionError) {
        if (connectionError) {
            if (weakSelf.userInfoEventHandler) {
                weakSelf.userInfoEventHandler(nil,connectionError);
                weakSelf.userInfoEventHandler = nil;
            }
        }
        else {
            DDUserInfoItem *userInfoItem = [[DDUserInfoItem alloc] initWithWeChatUserInfoDict:responseDict];
            if (weakSelf.userInfoEventHandler) {
                weakSelf.userInfoEventHandler(userInfoItem,connectionError);
                weakSelf.userInfoEventHandler = nil;
            }
        }
    }];
}

- (BOOL)shareWithProtocol:(id<DDShareSDKContentProtocol>)protocol
                    scene:(DDSSShareScene)shareScene
                     type:(DDSSShareType)shareType
           completeHandle:(DDShareContentEventHandler)completeHandle{
    self.shareScene = shareScene;
    self.shareContentEventHandler = completeHandle;
    if (self.shareContentEventHandler) {
        self.shareContentEventHandler(DDSSPlatformWeChat,self.shareScene,DDSSStateTypeBegan,nil);
    }
    if (shareType == DDSSShareTypeText && [protocol conformsToProtocol:@protocol(DDShareSDKTextProtocol)]) {
        return [self shareTextWithProtocol:(id<DDShareSDKTextProtocol>)protocol scene:shareScene completeHandle:completeHandle];
    }
    else if (shareType == DDSSShareTypeImage && [protocol conformsToProtocol:@protocol(DDShareSDKImageProtocol)]){
        return [self shareImageWithProtocol:(id<DDShareSDKImageProtocol>)protocol scene:shareScene completeHandle:completeHandle];
    }
    else if (shareType == DDSSShareTypeWebPage && [protocol conformsToProtocol:@protocol(DDShareSDKWebPageProtocol)]){
        return [self shareWebPageWithProtocol:(id<DDShareSDKWebPageProtocol>)protocol scene:shareScene completeHandle:completeHandle];
    }
    else {
        NSString *errorDescription = [NSString stringWithFormat:@"分享格式错误:%@ shareType:%lu",NSStringFromClass([protocol class]),(unsigned long)shareType];
        self.shareContentEventHandler = completeHandle;
        if (self.shareContentEventHandler) {
            NSError *error = [NSError errorWithDomain:@"format Error" code:1990 userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
            self.shareContentEventHandler(DDSSPlatformWeChat,self.shareScene,DDSSStateTypeFail,error);
        }
        return NO;
    }
}

- (BOOL)linkupWithItem:(DDLinkupItem *)item{
    JumpToBizProfileReq *bizProfile = [[JumpToBizProfileReq alloc]init];
    bizProfile.extMsg = item.extMsg;
    bizProfile.profileType = item.linkupType;
    bizProfile.username = item.username;
    BOOL ret = [WXApi sendReq:bizProfile];
    if (!ret) {
        NSLog(@"JumpToBizProfileReq failed");
    }
    return ret;
}

#pragma mark - Private Mehods

- (void)getTokenInfoWithAuthCode:(NSString *)authCode{
    __weak __typeof(&*self)weakSelf = self;
    [DDWeChatRequestHandle tokenWithAppid:self.appKey secret:DDWeChatAppSecret code:authCode compleleHandle:^(NSDictionary *responseDict, NSError *connectionError) {
        if (connectionError) {
            if (weakSelf.authEventHandler) {
                weakSelf.authEventHandler(DDSSAuthStateTypeFail,nil,connectionError);
                weakSelf.authEventHandler = nil;
            }
        }
        else {
            //缓存auth信息
            weakSelf.authItem = [[DDAuthItem alloc] initWithWeChatAuthDict:responseDict];
            if (weakSelf.authEventHandler) {
                weakSelf.authEventHandler(DDSSAuthStateTypeSuccess,weakSelf.authItem,nil);
                weakSelf.authEventHandler = nil;
            }
        }
    }];
}


#pragma mark - Share

- (BOOL)shareTextWithProtocol:(id<DDShareSDKTextProtocol>)protocol
                        scene:(DDSSShareScene)shareScene
               completeHandle:(DDShareContentEventHandler)completeHandle{
    NSString *text = [protocol ddShareText];
    return [self sendWithText:text mediaMessage:nil shareScene:shareScene];
}


- (BOOL)shareImageWithProtocol:(id<DDShareSDKImageProtocol>)protocol
                         scene:(DDSSShareScene)shareScene
                completeHandle:(DDShareContentEventHandler)completeHandle{
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    mediaMessage.title = [protocol ddShareImageWithTitle];
    
    NSData *imageData = [protocol ddShareImageWithImageData];
    //图片
    WXImageObject *ext = [WXImageObject object];
    if ([protocol respondsToSelector:@selector(ddShareImageWithImageURL)]) {
        ext.imageUrl = [protocol ddShareImageWithImageURL];
    }
    else {
        ext.imageData = [UIImage imageData:imageData maxBytes:DDWeChatImageDataMaxSize];
    }
    mediaMessage.mediaObject = ext;
    
    //缩略图
    NSData *thumbData = imageData;;
    if ([protocol respondsToSelector:@selector(ddShareImageWithThumbnailData)]) {
        thumbData = [protocol ddShareImageWithThumbnailData];
    }
    mediaMessage.thumbData = [UIImage imageData:thumbData maxBytes:DDWeChatThumbnailDataMaxSize];
    return [self sendWithText:nil mediaMessage:mediaMessage shareScene:shareScene];
}

- (BOOL)shareWebPageWithProtocol:(id<DDShareSDKWebPageProtocol>)protocol
                           scene:(DDSSShareScene)shareScene
                  completeHandle:(DDShareContentEventHandler)completeHandle{
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    mediaMessage.title = [protocol ddShareWebPageWithTitle];
    mediaMessage.description = [protocol ddShareWebPageWithDescription];
    
    NSData *thumbImageData = [protocol ddShareWebPageWithImageData];
    mediaMessage.thumbData = [UIImage imageData:thumbImageData maxBytes:DDWeChatThumbnailDataMaxSize];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [protocol ddShareWebPageWithWebpageUrl];
    mediaMessage.mediaObject = ext;
    return [self sendWithText:nil mediaMessage:mediaMessage shareScene:shareScene];
}

- (BOOL)sendWithText:(NSString *)text
        mediaMessage:(WXMediaMessage *)message
          shareScene:(DDSSShareScene)shareScene{
    int scene = WXSceneSession;
    if (shareScene == DDSSShareSceneWXSession) {
        scene = WXSceneSession;
    } else if (shareScene == DDSSShareSceneWXTimeline){
        scene = WXSceneTimeline;
    }
    
    SendMessageToWXReq *messageToWXReq = [[SendMessageToWXReq alloc] init];
    messageToWXReq.message = message;
    messageToWXReq.text = text;
    messageToWXReq.bText = text ? YES : NO;
    messageToWXReq.scene = scene;
    return [WXApi sendReq:messageToWXReq];
}

#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp*)resp{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        //登录授权获取到code
        if (self.authCodeHandle) {
            if (resp.errCode == WXSuccess) {
                SendAuthResp *authResp = (SendAuthResp *)resp;
                self.authCodeHandle(DDSSAuthCodeStateTypeSuccess,authResp.code,nil);
                self.authCodeHandle = nil;
            }
            else if (resp.errCode == WXErrCodeUserCancel){
                self.authCodeHandle(DDSSAuthCodeStateTypeCancel,nil,nil);
                self.authCodeHandle = nil;
            }
            else {
                NSError *error = [NSError errorWithDomain:@"WeChat Auth Code Error" code:resp.errCode userInfo:@{NSLocalizedDescriptionKey:resp.errStr}];
                self.authCodeHandle(DDSSAuthCodeStateTypeFail,nil,error);
                self.authCodeHandle = nil;
            }
        }
    }
    
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (self.shareContentEventHandler) {
            if (resp.errCode == WXSuccess) {
                self.shareContentEventHandler(DDSSPlatformWeChat,self.shareScene,DDSSStateTypeSuccess,nil);
                self.shareContentEventHandler = nil;
            }
            else if (resp.errCode == WXErrCodeUserCancel){
                self.shareContentEventHandler(DDSSPlatformWeChat,self.shareScene,DDSSStateTypeCancel,nil);
                self.shareContentEventHandler = nil;
            }
            else {
                NSError *error = [NSError errorWithDomain:@"WeChat Share Error" code:resp.errCode userInfo:@{NSLocalizedDescriptionKey:resp.errStr}];
                self.shareContentEventHandler(DDSSPlatformWeChat,self.shareScene,DDSSStateTypeFail,error);
                self.shareContentEventHandler = nil;
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
            if ([[dict objectForKey:@"CFBundleURLName"] isEqualToString:@"weixin"]) {
                urlSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
                break;
            }
        }
        if ([urlSchemes count] == 0) {
            _appKey = @"none error";
        }
        _appKey = [urlSchemes firstObject];
    }
    return _appKey;
}
@end
