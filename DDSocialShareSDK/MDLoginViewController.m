//
//  MDLoginViewController.m
//  MDLoginSDK
//
//  Created by lilingang on 15/10/13.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "MDLoginViewController.h"
#import "DDSocialShareSDKHandle.h"


@interface MDLoginViewController ()<UITableViewDataSource,UITableViewDelegate,DDShareSDKImageProtocol,DDShareSDKWebPageProtocol>

@property (nonatomic, copy) NSArray *sectionNameArray;
@property (nonatomic, copy) NSArray *sectionArray;

@end

@implementation MDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *section1 = @[@"MI",@"WeChat"];
    NSArray *section2 = @[@"QQ Friend",@"QZone",@"WeChat Session",@"WeChat Timeline",@"Sina"];
    NSArray *section3 = @[@"QQ Friend",@"QZone",@"WeChat Session",@"WeChat Timeline",@"Sina"];
    self.sectionArray = @[section1,section2,section3];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.sectionArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellidentifier";
    NSString *type = self.sectionArray[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = type;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sectionArray count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.sectionNameArray[section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:{ // GET Code
            [[DDSocialShareSDKHandle sharedInstance] getAuthCodeWithPlatform:[self ssPlatformWithRow:indexPath.row] controller:self compleleHandle:^(DDSSAuthCodeStateType state, NSString *code, NSError *error) {
                switch (state) {
                    case DDSSAuthCodeStateTypeBegan: {
                        NSLog(@"DDSSAuthCodeStateTypeBegan");
                        break;
                    }
                    case DDSSAuthCodeStateTypeSuccess: {
                        NSLog(@"DDSSAuthCodeStateTypeSuccess:%@",code);
                        break;
                    }
                    case DDSSAuthCodeStateTypeFail: {
                        NSLog(@"DDSSAuthCodeStateTypeFail:%@",error);
                        break;
                    }
                    case DDSSAuthCodeStateTypeCancel: {
                        NSLog(@"DDSSAuthCodeStateTypeCancel");
                        break;
                    }
                    default: {
                        break;
                    }
                }
            }];
            break;
        }
        case 1:{ // Share Image
            
            DDSSPlatform platform;
            if (indexPath.row == 0 || indexPath.row == 1) {
                platform = DDSSPlatformQQ;
            } else if (indexPath.row == 2 || indexPath.row == 3){
                platform = DDSSPlatformWeChat;
            } else {
                platform = DDSSPlatformSina;
            }
            [[DDSocialShareSDKHandle sharedInstance] shareWithPlatform:platform shareScene:[self ssShareSceneWithRow:indexPath.row] shareType:DDSSShareTypeImage protocol:self completeHandle:^(DDSSPlatform type, DDSSShareScene shareScene, DDSSStateType state, NSError *error) {
                
            }];
            break;
        }
        case 2:{ // Share URL
            DDSSPlatform platform;
            if (indexPath.row == 0 || indexPath.row == 1) {
                platform = DDSSPlatformQQ;
            } else if (indexPath.row == 2 || indexPath.row == 3){
                platform = DDSSPlatformWeChat;
            } else {
                platform = DDSSPlatformSina;
            }
            
            [[DDSocialShareSDKHandle sharedInstance] shareWithPlatform:platform shareScene:[self ssShareSceneWithRow:indexPath.row] shareType:DDSSShareTypeWebPage protocol:self completeHandle:^(DDSSPlatform type, DDSSShareScene shareScene, DDSSStateType state, NSError *error) {
                
            }];
            break;
        }
        default:
            break;
    }
}


#pragma mark - Private Logic


- (DDSSPlatform)ssPlatformWithRow:(NSUInteger)row{
    if (row == 0) {
        return DDSSPlatformMI;
    }
    else if (row == 1){
        return DDSSPlatformWeChat;
    }
    else if (row == 2){
        return DDSSPlatformSina;
    }
    else{
        return DDSSPlatformNone;
    }
}

- (DDSSShareScene)ssShareSceneWithRow:(NSUInteger)row{
    if (row == 0) {
        return DDSSShareSceneQQFrined;
    }
    else if (row == 1){
        return DDSSShareSceneQZone;
    }
    else if (row == 2){
        return DDSSShareSceneWXSession;
    }
    else if (row == 3){
        return DDSSShareSceneWXTimeline;
    }
    else if (row == 4){
        return DDSSShareSceneSina;
    }
    else {
        return DDSSShareSceneSina;
    }
}

#pragma mark - DDShareSDKImageProtocol

- (NSData *)ddShareImageWithImageData{
    UIImage *image = [UIImage imageNamed:@"login"];
    return UIImagePNGRepresentation(image);
}

- (NSString *)ddShareImageWithTitle{
    return @"测试分享图片";
}

- (NSString *)ddShareImageWithDescription{
    return @"这是图片的描述内容";
}

- (NSString *)ddShareImageWithWebpageUrl{
    return @"http://www.baidu.com";
}

#pragma mark - DDShareSDKWebPageProtocol

- (NSString *)ddShareWebPageWithTitle{
    return @"标题";
}

- (NSString *)ddShareWebPageWithDescription{
    return @"描述";
}

- (NSData *)ddShareWebPageWithImageData{
    UIImage *image = [UIImage imageNamed:@"login"];
    return UIImagePNGRepresentation(image);
}

- (NSString *)ddShareWebPageWithWebpageUrl{
    return @"http://www.baidu.com";
}

- (NSString *)ddShareWebPageWithObjectID{
    return @"1234567";
}

- (BOOL)ddShareWebPageByImageWithShareScence:(DDSSShareScene)shareScence{
    return YES;
}

@end
