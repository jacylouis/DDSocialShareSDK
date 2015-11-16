//
//  DDTencentHandle.m
//  HMLoginDemo
//
//  Created by lilingang on 15/8/1.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDTencentHandle.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#import "DDAuthItem.h"
#import "DDUserInfoItem.h"

#import "UIImage+zoom.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

NSString *const DDTencentAPIUserInfo =   @"https://graph.qq.com/user/get_user_info";

const CGFloat DDTencentThumbnailDataMaxSize = 1 * 1024.0 * 1024.0;
const CGFloat DDTencentImageDataMaxSize = 5 * 1024.0 * 1024.0;

@interface DDTencentHandle ()<TencentSessionDelegate,TCAPIRequestDelegate,QQApiInterfaceDelegate>

@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, copy) DDAuthEventHandler authEventHandler;
@property (nonatomic, copy) DDGetUserInfoEventHandler userInfoEventHandler;
@property (nonatomic, copy) DDShareContentEventHandler shareContentEventHandler;

@property (nonatomic, assign) DDSSShareScene shareScene;

@end

@implementation DDTencentHandle

- (instancetype)init{
    self = [super init];
    if (self) {
        //必须优先注册一下
        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:self.appKey andDelegate:self];
    }
    return self;
}

+ (BOOL)isQQInstalled{
    return [TencentOAuth iphoneQQInstalled];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    if ([TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    else {
        return [QQApiInterface handleOpenURL:url delegate:self];
    }
}

- (void)authCompleteHandle:(DDAuthEventHandler)completeHandle{
    self.authEventHandler = completeHandle;
    if (self.authEventHandler) {
        self.authEventHandler(DDSSAuthStateTypeBegan,nil,nil);
    }
    NSArray *permissions = @[kOPEN_PERMISSION_GET_USER_INFO,
                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                             kOPEN_PERMISSION_ADD_ALBUM,
                             kOPEN_PERMISSION_ADD_IDOL,
                             kOPEN_PERMISSION_ADD_ONE_BLOG,
                             kOPEN_PERMISSION_ADD_PIC_T,
                             kOPEN_PERMISSION_ADD_SHARE,
                             kOPEN_PERMISSION_ADD_TOPIC,
                             kOPEN_PERMISSION_CHECK_PAGE_FANS,
                             kOPEN_PERMISSION_DEL_IDOL,
                             kOPEN_PERMISSION_DEL_T,
                             kOPEN_PERMISSION_GET_FANSLIST,
                             kOPEN_PERMISSION_GET_IDOLLIST,
                             kOPEN_PERMISSION_GET_INFO,
                             kOPEN_PERMISSION_GET_OTHER_INFO,
                             kOPEN_PERMISSION_GET_REPOST_LIST,
                             kOPEN_PERMISSION_LIST_ALBUM,
                             kOPEN_PERMISSION_UPLOAD_PIC,
                             kOPEN_PERMISSION_GET_VIP_INFO,
                             kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                             kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                             kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO];
    if ([TencentOAuth iphoneQQInstalled] && [TencentOAuth iphoneQQSupportSSOLogin]) {
        [self.tencentOAuth authorize:permissions inSafari:NO];
    } else {
        [self.tencentOAuth authorize:permissions inSafari:YES];
    }
}

- (void)getUserInfoCompleteHandle:(DDGetUserInfoEventHandler)completeHandle{
    self.userInfoEventHandler = completeHandle;
    NSDictionary *params = @{@"access_token":self.tencentOAuth.accessToken,
                             @"oauth_consumer_key":self.tencentOAuth.appId,
                             @"openid":self.tencentOAuth.openId,};
    TCAPIRequest *request = [self.tencentOAuth cgiRequestWithURL:[NSURL URLWithString:DDTencentAPIUserInfo] method:@"GET" params:params callback:self];
    [self.tencentOAuth sendAPIRequest:request callback:self];
}

- (BOOL)shareWithProtocol:(id<DDShareSDKContentProtocol>)protocol
                    scene:(DDSSShareScene)shareScene
                     type:(DDSSShareType)shareType
           completeHandle:(DDShareContentEventHandler)completeHandle{
    self.shareScene = shareScene;
    self.shareContentEventHandler = completeHandle;
    if (self.shareContentEventHandler) {
        self.shareContentEventHandler(DDSSPlatformQQ,self.shareScene,DDSSStateTypeBegan,nil);
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
        NSLog(@"%@",errorDescription);
        self.shareContentEventHandler = completeHandle;
        if (self.shareContentEventHandler) {
            NSError *error = [NSError errorWithDomain:@"format Error" code:1990 userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
            self.shareContentEventHandler(DDSSPlatformQQ,self.shareScene,DDSSStateTypeFail,error);
        }
        return NO;
    }
}

#pragma mark - Private Methods

#pragma mark - Share

- (BOOL)shareTextWithProtocol:(id<DDShareSDKTextProtocol>)protocol
                        scene:(DDSSShareScene)shareScene
               completeHandle:(DDShareContentEventHandler)completeHandle{
    NSString *text = [protocol ddShareText];
    QQApiTextObject *textObject = [QQApiTextObject objectWithText:text];
    return [self sendApiObject:textObject shareScene:shareScene];
}


- (BOOL)shareImageWithProtocol:(id<DDShareSDKImageProtocol>)protocol
                         scene:(DDSSShareScene)shareScene
                completeHandle:(DDShareContentEventHandler)completeHandle{
    
    NSData *imageData = [protocol ddShareImageWithImageData];
    NSData *thumbnailData = imageData;
    if ([protocol respondsToSelector:@selector(ddShareImageWithThumbnailData)]) {
        //optional
        thumbnailData = [protocol ddShareImageWithThumbnailData];
    }
    imageData = [UIImage imageData:imageData maxBytes:DDTencentImageDataMaxSize];
    thumbnailData = [UIImage imageData:thumbnailData maxBytes:DDTencentThumbnailDataMaxSize];
    
    NSString *title = [protocol ddShareImageWithTitle];
    NSString *descriptionString = [protocol ddShareImageWithDescription];
    NSString *webpageURL = [protocol ddShareImageWithWebpageUrl];
    
    if (shareScene == DDSSShareSceneQZone) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")){
            NSString *text = @"";
            if ([protocol respondsToSelector:@selector(ddShareImageText)]) {
                //optional
                text = [protocol ddShareImageText];
            }
            QQApiImageArrayForQZoneObject *imageQZoneObject = [self qzoneImageObjectWithText:nil title:title description:descriptionString url:webpageURL imageData:imageData];
            return [self sendApiObject:imageQZoneObject shareScene:shareScene];
        }
        else {
            QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:webpageURL]
                                                                   title:title
                                                             description:descriptionString
                                                        previewImageData:thumbnailData
                                                       targetContentType:QQApiURLTargetTypeNews];
            return [self sendApiObject:newsObject shareScene:shareScene];

        }
    }
    else {
        QQApiImageObject *imageObject = [QQApiImageObject objectWithData:imageData
                                                        previewImageData:thumbnailData
                                                                   title:title
                                                             description:descriptionString];
        return [self sendApiObject:imageObject shareScene:shareScene];
    }
}

- (BOOL)shareWebPageWithProtocol:(id<DDShareSDKWebPageProtocol>)protocol
                           scene:(DDSSShareScene)shareScene
                  completeHandle:(DDShareContentEventHandler)completeHandle{
    NSString *webpageURL = [protocol ddShareWebPageWithWebpageUrl];
    NSString *title = [protocol ddShareWebPageWithTitle];
    NSString *descriptionString = [protocol ddShareWebPageWithDescription];
    NSData *imageData = [protocol ddShareWebPageWithImageData];
    if (shareScene == DDSSShareSceneQZone && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")){
        NSString *text = @"";
        if ([protocol respondsToSelector:@selector(ddShareWebPageText)]) {
            text = [protocol ddShareWebPageText];
        }
        imageData = [UIImage imageData:imageData maxBytes:DDTencentImageDataMaxSize];
        QQApiImageArrayForQZoneObject *imageQZoneObject = [self qzoneImageObjectWithText:nil title:title description:descriptionString url:webpageURL imageData:imageData];
        return [self sendApiObject:imageQZoneObject shareScene:shareScene];
    } else {
        imageData = [UIImage imageData:imageData maxBytes:DDTencentThumbnailDataMaxSize];
        QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:webpageURL]
                                                               title:title
                                                         description:descriptionString
                                                    previewImageData:imageData
                                                   targetContentType:QQApiURLTargetTypeNews];
        return [self sendApiObject:newsObject shareScene:shareScene];
    }
}

- (QQApiImageArrayForQZoneObject *)qzoneImageObjectWithText:(NSString *)text title:(NSString *)title description:(NSString *)description url:(NSString *)url imageData:(NSData *)imageData{
    NSString *shareText = @"";
    if ([text length] && text) {
        shareText = [shareText stringByAppendingString:text];
    }
    if ([title length] && title) {
        shareText = [shareText stringByAppendingString:title];
    }
    if ([description length] && description) {
        shareText = [shareText stringByAppendingString:description];
    }
    if ([url length] && url) {
        shareText = [shareText stringByAppendingString:url];
    }
    QQApiImageArrayForQZoneObject *imageQZoneObject = [[QQApiImageArrayForQZoneObject alloc] initWithImageArrayData:@[imageData] title:shareText];
    [imageQZoneObject setCflag:kQQAPICtrlFlagQQShare];
    return imageQZoneObject;
}

- (BOOL)sendApiObject:(QQApiObject *)apiObject
           shareScene:(DDSSShareScene)shareScene{

    SendMessageToQQReq *qqReq = [SendMessageToQQReq reqWithContent:apiObject];
    QQApiSendResultCode sendResult = EQQAPISENDSUCESS;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") ||
        shareScene == DDSSShareSceneQQFrined) {
        sendResult = [QQApiInterface sendReq:qqReq];
    }
    else {
        sendResult = [QQApiInterface SendReqToQZone:qqReq];
    }

    NSError *error = nil;
    switch (sendResult) {
        case EQQAPIQQNOTINSTALLED://失败
        case EQQAPIQQNOTSUPPORTAPI:{//不支持的api
            error = [NSError errorWithDomain:@"QQ API Error" code:EQQAPIMESSAGECONTENTINVALID userInfo:@{NSLocalizedDescriptionKey:@"QQ安装失败或不支持的API"}];
            break;
        }
        case EQQAPIMESSAGETYPEINVALID://失败
        case EQQAPIMESSAGECONTENTNULL://失败
        case EQQAPIMESSAGECONTENTINVALID:{//失败
            error = [NSError errorWithDomain:@"QQ Share Error" code:EQQAPIMESSAGECONTENTINVALID userInfo:@{NSLocalizedDescriptionKey:@"分享内容不合法\n"}];
            break;
        }
        case EQQAPIAPPNOTREGISTED:{//失败
            error = [NSError errorWithDomain:@"QQ Share Error" code:EQQAPIAPPNOTREGISTED userInfo:@{NSLocalizedDescriptionKey:@"该设备未安装QQ客户端\n或该QQ版本暂不支持\n无法分享"}];
        }
            break;
        case EQQAPIQQNOTSUPPORTAPI_WITH_ERRORSHOW:{//失败
            error = [NSError errorWithDomain:@"QQ Share Error" code:EQQAPIQQNOTSUPPORTAPI_WITH_ERRORSHOW userInfo:@{NSLocalizedDescriptionKey:@"分享失败"}];
        }
            break;
        case EQQAPISENDFAILD:{//失败
            error = [NSError errorWithDomain:@"QQ Share Error" code:EQQAPISENDFAILD userInfo:@{NSLocalizedDescriptionKey:@"无法分享失败"}];
        }
            break;
        case EQQAPIQZONENOTSUPPORTTEXT:{//qzone分享不支持text类型分享
            error = [NSError errorWithDomain:@"QZone Share Error" code:EQQAPIQZONENOTSUPPORTTEXT userInfo:@{NSLocalizedDescriptionKey:@"qzone分享不支持text类型分享"}];
        }
            break;
        case EQQAPIQZONENOTSUPPORTIMAGE:{//qzone分享不支持image类型分享
            error = [NSError errorWithDomain:@"QZone Share Error" code:EQQAPIQZONENOTSUPPORTIMAGE userInfo:@{NSLocalizedDescriptionKey:@"qzone分享不支持image类型分享"}];
        }
            break;
        default:
            break;
    }
    if (error && self.shareContentEventHandler) {
        self.shareContentEventHandler(DDSSPlatformQQ,self.shareScene,DDSSStateTypeFail,error);
        self.shareContentEventHandler = nil;
    }
    return !error;
}


#pragma mark - TencentLoginDelegate
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin{
    if (self.authEventHandler) {
        DDAuthItem *authItem = [[DDAuthItem alloc] initWithTencentOAuth:self.tencentOAuth];
        self.authEventHandler(DDSSAuthStateTypeSuccess,authItem,nil);
        self.authEventHandler = nil;
    }
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled{
    if (self.authEventHandler) {
        if (cancelled) {
            self.authEventHandler(DDSSAuthStateTypeCancel,nil,nil);
            self.authEventHandler = nil;
        }
        else {
            NSError *error  = [NSError errorWithDomain:@"tencent Login ERROR" code:1990 userInfo:@{NSLocalizedDescriptionKey:@"登录失败"}];
            self.authEventHandler(DDSSAuthStateTypeFail,nil,error);
            self.authEventHandler = nil;
        }
    }
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork{
    if (self.authEventHandler) {
        NSError *error  = [NSError errorWithDomain:@"tencent NetWork ERROR" code:1990 userInfo:@{NSLocalizedDescriptionKey:@"网络出错了"}];
        self.authEventHandler(DDSSAuthStateTypeFail,nil,error);
        self.authEventHandler = nil;
    }
}

#pragma mark - TCAPIRequestDelegate

- (void)cgiRequest:(TCAPIRequest *)request didResponse:(APIResponse *)response{
    if ([[request.apiURL absoluteString] isEqualToString:DDTencentAPIUserInfo]) {
         //获取用户信息
        if (self.userInfoEventHandler) {
            if (response.retCode == 0) {
                DDUserInfoItem *infoItem = [[DDUserInfoItem alloc] initWithTencentUserInfoDict:response.jsonResponse];
                self.userInfoEventHandler(infoItem,nil);
                self.userInfoEventHandler = nil;
            }
            else {
                NSString *errorMessage = response.jsonResponse[@"msg"];
                NSError *error = [NSError errorWithDomain:@"GET USer info Error" code:response.retCode userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                self.userInfoEventHandler(nil,error);
                self.userInfoEventHandler = nil;
            }
        }
    }
}

#pragma mark - QQApiInterfaceDelegate

- (void)onReq:(QQBaseReq *)req{
    //只是为了消除警告
}

- (void)onResp:(QQBaseResp *)resp{
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        if (self.shareContentEventHandler) {
            NSInteger result = [resp.result integerValue];
            if (result == 0) {
                self.shareContentEventHandler(DDSSPlatformQQ,self.shareScene,DDSSStateTypeSuccess,nil);
                self.shareContentEventHandler = nil;
            }
            else if (result == -4) {
                self.shareContentEventHandler(DDSSPlatformQQ,self.shareScene,DDSSStateTypeCancel,nil);
                self.shareContentEventHandler = nil;
            }
            else {
                NSError *error = [NSError errorWithDomain:@"QQ Share Error" code:result userInfo:@{NSLocalizedDescriptionKey:resp.errorDescription}];
                self.shareContentEventHandler(DDSSPlatformQQ,self.shareScene,DDSSStateTypeFail,error);
                self.shareContentEventHandler = nil;
            }
        }
    }
}

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response{
    //只是为了消除警告
}
#pragma mark - Getter and Setter

- (NSString *)appKey{
    if (!_appKey) {
        NSArray *urlTypesArray = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
        NSArray *urlSchemes;
        for (NSDictionary *dict in urlTypesArray) {
            if ([[dict objectForKey:@"CFBundleURLName"] isEqualToString:@"tencentopenapi"]) {
                urlSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
                break;
            }
        }
        if ([urlSchemes count] == 0) {
            _appKey = @"none error";
        }
        _appKey = [urlSchemes firstObject];
        _appKey = [_appKey stringByReplacingOccurrencesOfString:@"tencent" withString:@""];
    }
    return _appKey;
}

@end
