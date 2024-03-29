//
//  DDMILoginViewController.m
//  HMLoginDemo
//
//  Created by lilingang on 15/8/4.
//  Copyright (c) 2015年 lilingang. All rights reserved.
//

#import "DDMILoginViewController.h"
#import "DDMICircleIndicator.h"

#import "DDMIDownLoader.h"

#import "UIView+DDFrame.h"
#import "UIView+DDAction.h"

@interface DDMILoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIImageView *inputbackImageView;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIImageView *codeImageView;

@property (weak, nonatomic) IBOutlet UILabel *errorTipLabel;
@property (weak, nonatomic) IBOutlet DDMICircleIndicator *indicatorView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputContentViewHeightConstraint;

@property (nonatomic, assign) DDMILoginType loginType;
@property (nonatomic, strong) DDMIRequestHandle *requestHandle;
@property (nonatomic, strong) DDMIDownLoader *downLoader;

@end

@implementation DDMILoginViewController

- (instancetype)initWithRequestHandle:(DDMIRequestHandle *)requestHandle{
    self = [super initWithNibName:@"DDMILoginViewController" bundle:nil];
    if (self) {
        self.requestHandle = requestHandle;
        self.requestHandle.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginType = DDMILoginTypeImageVerification;
    
    self.loginButton.enabled = NO;
    self.loginButton.layer.borderWidth = 1;
    self.loginButton.layer.cornerRadius = self.loginButton.ddHeight/2.0;
    self.loginButton.layer.borderColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1].CGColor;
    [self.loginButton setBackgroundColor:[UIColor colorWithRed:252/255.0f green:252/255.0f blue:252/255.0f alpha:1]];

    [self.codeImageView ddAddTarget:self tapAction:@selector(codeImageViewTap)];
    
    //隐藏键盘
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self switchLoginType:DDMILoginTypeDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hidenKeyboard:nil];
}

#pragma mark - Actions

- (IBAction)loginButtonAction:(id)sender{
    [self hidenKeyboard:nil];
    self.errorTipLabel.alpha = 0.0;
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *code = self.codeTextField.text;
    
    if (![account length]) {
        [self displayAndAutoDisMissErrorTipLabelWithText:@"账号不能为空"];
        return;
    }
    if (![password length]) {
        [self displayAndAutoDisMissErrorTipLabelWithText:@"密码不能为空"];
        return;
    }
    
    if (self.loginType == DDMILoginTypeImageVerification && ![code length]) {
        [self displayAndAutoDisMissErrorTipLabelWithText:@"验证码不能为空"];
        return;
    }
    
    self.loginButton.enabled = NO;
    self.view.userInteractionEnabled = NO;
    if (self.loginType == DDMILoginTypeImageVerification) {
        [self.requestHandle loginWithAccount:account password:password verifyCode:code];
    }
    else {
        [self.requestHandle loginWithAccount:account password:password verifyCode:nil];
    }
    [self.indicatorView startAnimation];
}

- (void)codeImageViewTap{
    [self changeImageVerificationCodeWithURLString:nil];
}

#pragma mark - Private Methods

- (void)switchLoginType:(DDMILoginType)loginType{
    if (self.loginType == loginType) {
        return;
    }
    self.loginType = loginType;
    if (loginType == DDMILoginTypeDefault) {
        self.codeTextField.hidden = YES;
        self.codeImageView.hidden = YES;
        self.passwordTextField.returnKeyType = UIReturnKeyDone;
        
        self.contentView.ddHeight = 337;
        self.inputbackImageView.ddHeight = 112;
        self.inputbackImageView.image = [UIImage imageNamed:@"dd_input_bg"];
    }
    else {
        self.codeTextField.hidden = NO;
        self.codeImageView.hidden = NO;
        self.passwordTextField.returnKeyType = UIReturnKeyNext;
        self.loginButton.enabled = NO;
        
        self.contentView.ddHeight = 387;
        self.inputbackImageView.ddHeight = 162;
        self.inputbackImageView.image = [UIImage imageNamed:@"dd_input_bg_verification"];
    }
    self.contentViewHeightConstraint.constant = self.contentView.ddHeight;
    self.inputContentViewHeightConstraint.constant = self.inputbackImageView.ddHeight;
}

- (void)changeImageVerificationCodeWithURLString:(NSString *)urlString{
    self.codeImageView.userInteractionEnabled = NO;
    __weak __typeof(&*self)weakSelf = self;
    [self.downLoader loadLoginCodeImageWithURLString:urlString account:self.accountTextField.text completeHandle:^(NSData *data, NSError *error) {
        if (error) {
            NSInteger errorCode = [error code];
            NSInteger errorUserCode = [[[error userInfo] objectForKey:@"code"] integerValue];
            NSString *errorMessage = [[[error userInfo] objectForKey:@"desc"] stringByAppendingFormat:@"(%ld)",(long)errorUserCode];
            if (errorCode == -1009 ||
                errorCode == -1005 ||
                errorUserCode == -1009 ||
                errorUserCode == -1005) {
                errorMessage = @"网络未连接";
            }
            else if (errorCode == -1001 ||
                     errorUserCode == -1001){
                errorMessage = @"请求超时";
            }
            [weakSelf displayErrorTipLabelWithText:errorMessage];
        }
        else {
            UIImage *codeImage = [UIImage imageWithData:data];
            weakSelf.codeImageView.image = codeImage;
        }
        weakSelf.codeImageView.userInteractionEnabled = YES;
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self loginButtonStateChangedWithTextField:textField text:textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    NSString *tmpString = @"";
    if ([string length]) {//输入
        tmpString = [textField.text stringByAppendingString:string];
    }
    else {//删除
        tmpString = [textField.text substringToIndex:[textField.text length] > 0 ? [textField.text length] - 1 : 0];
    }
    [self loginButtonStateChangedWithTextField:textField text:tmpString];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.accountTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        if (self.loginType == DDMILoginTypeDefault) {
            [self.passwordTextField resignFirstResponder];
        }
        else {
            if (textField == self.passwordTextField){
                [self.codeTextField becomeFirstResponder];
            } else {
                [self.codeTextField resignFirstResponder];
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    [self loginButtonStateChangedWithTextField:textField text:nil];
    return YES;
}

- (void)loginButtonStateChangedWithTextField:(UITextField *)textField text:(NSString *)text{
    self.errorTipLabel.alpha = 0.0;

    NSString *accountString = self.accountTextField.text;
    NSString *passwordString = self.passwordTextField.text;
    NSString *codeString = self.codeTextField.text;
    if (textField == self.accountTextField) {
        accountString = text;
    } else if (textField == self.passwordTextField){
        passwordString = text;
    } else if (textField == self.codeTextField){
        codeString = text;
    }
    if ([accountString length] && [passwordString length]) {
        if ((self.loginType == DDMILoginTypeImageVerification && [codeString length]) ||
            self.loginType == DDMILoginTypeDefault) {
            self.loginButton.enabled = YES;
        } else {
            self.loginButton.enabled = NO;
        }
    }
    else {
        self.loginButton.enabled = NO;
    }
}

#pragma mark - DDMIRequestHandleDelegate

- (void)requestHandle:(DDMIRequestHandle *)requestHandle successedNeedDynamicToken:(BOOL)needDynamicToken{
    [self.indicatorView stopAnimation];
    self.loginButton.enabled = YES;
    self.view.userInteractionEnabled = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginViewController:successNeedDaynamicCode:)]) {
        [self.delegate loginViewController:self successNeedDaynamicCode:needDynamicToken];
    }
}

- (void)requestHandle:(DDMIRequestHandle *)requestHandle failedWithType:(DDMIErrorType)errorType errorMessage:(NSString *)errorMessage error:(NSError *)error{
    [self.indicatorView stopAnimation];
    self.loginButton.enabled = YES;
    self.view.userInteractionEnabled = YES;
    if (errorType == DDMIErrorVerificationCode) {
        if (self.loginType == DDMILoginTypeDefault) {
            [self switchLoginType:DDMILoginTypeImageVerification];
            errorMessage = @"请输入验证码";
        }
        
        UIImage *captImage = [error.userInfo objectForKey:@"captImage"];
        if (captImage) {
            self.codeImageView.image = captImage;
        }
        else {
            NSString *captchaUrl = [error.userInfo objectForKey:@"captchaUrl"];
            [self changeImageVerificationCodeWithURLString:captchaUrl];
        }
    }
    [self displayErrorTipLabelWithText:errorMessage];
}

- (void)displayErrorTipLabelWithText:(NSString *)text{
    self.errorTipLabel.text = text;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.errorTipLabel.alpha = 1.0;
    } completion:nil];
}

- (void)displayAndAutoDisMissErrorTipLabelWithText:(NSString *)text{
    self.errorTipLabel.text = text;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.errorTipLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.errorTipLabel.alpha = 0.0;
            } completion:nil];
        });
    }];
}


#pragma mark - Keyboard

- (void)hidenKeyboard:(UIGestureRecognizer *)recognizer{
    if ([self.accountTextField isFirstResponder]) {
        [self.accountTextField resignFirstResponder];
    }
    if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
    if ([self.codeTextField isFirstResponder]) {
        [self.codeTextField resignFirstResponder];
    }
}

#pragma mark - Notification

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = CGRectGetMinY(keyboardRect);
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (keyboardY == self.view.ddHeight) {
                             self.contentView.ddTop = 64;
                         } else {
                             CGFloat offset = keyboardY - self.contentView.ddHeight;
                             //fix bug the input box shows is not complete for 480 screen
                             if (CGRectGetHeight([UIScreen mainScreen].bounds) <= 480) {
                                 if ([self.accountTextField isFirstResponder]) {
                                     offset += 30; 
                                 }
                             }
                             if (offset < 64) {
                                 self.contentView.ddTop = offset;
                             }
                         }
                     } completion:nil];
    self.contentViewTopConstraint.constant = self.contentView.ddTop;
}


#pragma mark - Getter and Setter

- (DDMIDownLoader *)downLoader{
    if (!_downLoader) {
        _downLoader = [[DDMIDownLoader alloc] init];
    }
    return _downLoader;
}

@end
