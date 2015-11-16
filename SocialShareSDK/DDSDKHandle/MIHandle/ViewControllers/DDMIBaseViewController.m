//
//  DDMIBaseViewController.m
//  HMLoginDemo
//
//  Created by lilingang on 15/8/5.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDMIBaseViewController.h"

@interface DDMIBaseViewController ()

@end

@implementation DDMIBaseViewController

- (void)dealloc{
    NSLog(@"%@ dealloc",[[self class] description]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    self.view.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    //LeftBar
    UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [backButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}


- (void)cancelButtonAction:(id)sender{
    if (self.cancelDelegate && [self.cancelDelegate respondsToSelector:@selector(viewControllerCanceled:)]) {
        [self.cancelDelegate viewControllerCanceled:self];
    }
}

@end
