//
//  DDMIRequestHandle.m
//  HMLoginDemo
//
//  Created by lilingang on 15/8/3.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDMIRequestHandle.h"
#import <XMPassport/XMPassport.h>
#import <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@interface DDMIRequestHandle ()<MPSessionDelegate>

//小米授权过程中保证xmPassport唯一
@property (nonatomic, strong) XMPassport *xmPassport;

@property (nonatomic, copy) NSString *account;

@end

@implementation DDMIRequestHandle

- (void)loginWithAccount:(NSString *)account
                password:(NSString *)passWord
              verifyCode:(NSString *)verifyCode{
    self.account = account;
    self.xmPassport = [[XMPassport alloc] initWithUserId:account sid:@"oauth2.0" andDelegate:self];
    if ([verifyCode length]) {
        [self.xmPassport loginWithPassword:passWord encryptedOrNot:NO andVerifyCode:verifyCode];
    }
    else {
        [self.xmPassport loginWithPassword:passWord encryptedOrNot:NO];
    }
}

- (void)checkOTPCode:(NSString *)OTPCode trustDevice:(BOOL)isTrust{
    [self.xmPassport checkOTPCode:OTPCode trustOrNot:isTrust];
}

- (void)userInfoWithAppID:(NSString *)appID
              accessToken:(NSString *)accessToken
                   mackey:(NSString *)mackey
           compleleHandle:(DDMIRequestBlock)compleleHandle{
    NSInteger time = (NSInteger)[[NSDate date] timeIntervalSince1970];
    
    NSString *nonceString = [NSString stringWithFormat:@"%d:%ld",arc4random(),(long)time];
    NSString *hostName = @"open.account.xiaomi.com";
    NSString *urlName = @"/user/profile";
    NSString *querString = [NSString stringWithFormat:@"clientId=%@&token=%@",appID,accessToken];
    
    NSString *signatureString = [self macAccessTokenSignatureString:nonceString method:@"GET" host:hostName uriPath:urlName qs:querString];
    
    NSString *urlString = [NSString stringWithFormat:@"https://%@%@?%@",hostName,urlName,querString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSString *hash = [self hmacsha1:signatureString secret:mackey];
    NSString *authorization = [self miAPIHeaderAuthorizationWithToken:accessToken nonce:nonceString hash:hash];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (compleleHandle) {
            if (connectionError) {
                compleleHandle(nil,connectionError);
            }
            else {
                NSError *error = nil;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                
                if (error) {
                    compleleHandle(nil,error);
                }
                else{
                    NSInteger code = [[jsonDict objectForKey:@"code"] integerValue];
                    if (code == 0) {
                        compleleHandle([jsonDict objectForKey:@"data"],nil);
                    }
                    else {
                        NSString *description = [jsonDict objectForKey:@"description"];
                        error = [NSError errorWithDomain:@"GETUseInfo Error" code:code userInfo:@{NSLocalizedDescriptionKey:description}];
                        compleleHandle(nil,error);
                    }
                }
            }
        }
    }];
}

- (NSString *)macAccessTokenSignatureString:(NSString *)nonce method:(NSString *)method host:(NSString *)host uriPath:(NSString *)uriPath qs:(NSString *)qs{
    NSString *string = [nonce stringByAppendingString:@"\n"];
    string = [[string stringByAppendingString:method] stringByAppendingString:@"\n"];
    string = [[string stringByAppendingString:host] stringByAppendingString:@"\n"];
    string = [[string stringByAppendingString:uriPath] stringByAppendingString:@"\n"];
    if ([qs length] && qs) {
        string = [[string stringByAppendingString:qs] stringByAppendingString:@"\n"];
    }
    return string;
}

- (NSString *)miAPIHeaderAuthorizationWithToken:(NSString *)token nonce:(NSString *)nonce hash:(NSString *)hashMAC{
    NSString *string = [NSString stringWithFormat:@"MAC access_token=%@,nonce=%@,mac=%@",token,nonce,hashMAC];
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)string, NULL, NULL,  kCFStringEncodingUTF8 ));
    return encodedString;
}

- (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *macData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [[NSString alloc] initWithData:macData encoding:NSUTF8StringEncoding];
    return hash;
}


#pragma mark - MPSessionDelegate

- (void)passportDidLogin:(XMPassport *)passport{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestHandle:successedNeedDynamicToken:)]) {
        [self.delegate requestHandle:self successedNeedDynamicToken:NO];
    }
}


- (void)passport:(XMPassport *)passport failedWithError:(NSError *)error{
    NSLog(@"XMPassport Error:%@ code:%ld userInfo:%@",[error localizedDescription],(long)[error code],error.userInfo);
    
    NSInteger errorCode = [error code];
    NSInteger userInfoErrorCode = [[[error userInfo] objectForKey:@"code"] integerValue];
    NSString *errorMessage = [[[error userInfo] objectForKey:@"desc"] stringByAppendingFormat:@"(%ld)",(long)userInfoErrorCode];
    if (![errorMessage length]) {
        errorMessage = [[error localizedDescription] stringByAppendingFormat:@"(%ld)",(long)errorCode];
    }
    DDMIErrorType errorType = DDMIErrorUnkwon;
    if (errorCode == -1009 ||
        errorCode == -1005 ||
        userInfoErrorCode == -1009 ||
        userInfoErrorCode == -1005) {
        errorType = DDMIErrorNetworkNotConnected;
        errorMessage = @"网络未连接";
    }
    
    if (errorCode == -1001 ||
        errorCode == -1002 ||
        userInfoErrorCode == -1001 ||
        userInfoErrorCode == -1002 ) {
        //请求超时
        errorType = DDMIErrorTimeOut;
        errorMessage = @"请求超时";
    }
    
    if (errorCode == -1003 ||
        userInfoErrorCode == -1003 ) {
        //无法连接服务器
        errorType = DDMIErrorNotReachServer;
        errorMessage = @"无法连接服务器";
    }
    
    if (errorCode == 403 ||
        userInfoErrorCode == 403 ) {
        //您的操作频率过快，请稍后再试.
        errorType = DDMIErrorOperationFrequent;
        errorMessage = @"您的操作频率过快，请稍后再试.";
    }
    
    if (errorCode == 70016 ||
        errorCode == 20003 ||
        userInfoErrorCode == 70016 ||
        userInfoErrorCode == 20003 ) {
        //账号或密码错误
        errorType = DDMIErrorAccountOrPassword;
        errorMessage = @"账号或密码错误,请重新填写.";
    }

    if (errorCode == 81003 ||
        userInfoErrorCode == 81003 ) {
        //需要二次验证 或 动态口令错误
        errorType = DDMIErrorNeedDynamicToken;
    }

    if (errorCode == 87001 ||
        userInfoErrorCode == 87001 ) {
        //您输入的验证码有误
        errorType = DDMIErrorVerificationCode;
        errorMessage = @"您输入的验证码有误";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errorType == DDMIErrorNeedDynamicToken) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestHandle:successedNeedDynamicToken:)]) {
                [self.delegate requestHandle:self successedNeedDynamicToken:YES];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestHandle:failedWithType:errorMessage:error:)]) {
                [self.delegate requestHandle:self failedWithType:errorType errorMessage:errorMessage error:error];
            }
        }
    });
}

@end
