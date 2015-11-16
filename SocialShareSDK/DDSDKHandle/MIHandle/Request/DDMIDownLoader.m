//
//  DDMIDownLoader.m
//  HMLoginDemo
//
//  Created by lilingang on 15/8/5.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDMIDownLoader.h"

@interface DDMIDownLoader ()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) NSURLConnection *urlConnection;

@property (nonatomic, copy) DDMIDownLoaderEventHandler completeHandle;

@end

@implementation DDMIDownLoader

- (void)loadLoginCodeImageWithURLString:(NSString *)urlString
                                account:(NSString *)account
                         completeHandle:(DDMIDownLoaderEventHandler)completeHandle{
    if ([urlString length]) {
        NSString *url = [@"https://account.xiaomi.com" stringByAppendingString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (completeHandle) {
            completeHandle(data,nil);
        }
        return;
    }
    self.completeHandle = completeHandle;
    self.imageData = [[NSMutableData alloc] init];
    NSString *url = [NSString stringWithFormat:@"https://account.xiaomi.com/pass/getCode?icodeType=login&phone=%@",account];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    self.urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate
//每次成功请求到数据后将调下此方法
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //把每次得到的数据依次放到数组中，这里还可以自己做一些进度条相关的效果
    [self.imageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (self.completeHandle) {
        self.completeHandle(nil,error);
    }
    self.imageData =nil;
    self.urlConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (self.completeHandle) {
        self.completeHandle(self.imageData,nil);
    }
    self.imageData =nil;
    self.urlConnection =nil;
}

@end
