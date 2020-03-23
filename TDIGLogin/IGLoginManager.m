//
/*******************************************************************************
    Copyright © 2020 Adrian. All rights reserved.

    File name:     IGLoginManager.m
    Author:        Adrian

    Project name:  GPInstagramLogin

    Description:
    

    History:
            2020/3/23: File created.

********************************************************************************/
    

#import "IGLoginManager.h"
#import "IGInsLoginViewController.h"
#import "IGWebLoginViewController.h"

@implementation IGLoginManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (UIViewController *)loginViewControllerWithType:(IGLoginType)type {
    if (type == IGLoginTypeAPI) {
        IGInsLoginViewController *loginVc = [[IGInsLoginViewController alloc] init];
        loginVc.showCloseBtn = self.showCloseBtn;
        loginVc.beginLoginHandler = self.beginLoginHandler;
        loginVc.beginGetUserInfoHandler = self.beginGetUserInfoHandler;
        loginVc.closeLoginPageHandler = self.closeLoginPageHandler;
        loginVc.authCompleteHandler = self.authCompleteHandler;
        loginVc.getUserInfoComplete = self.getUserInfoComplete;
        loginVc.loginComplete = ^(BOOL success, BOOL checkPoint, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull loginUserDic, NSString * _Nonnull cookie) {
            self.loginComplete(success, NO, @"", @{}, cookie, @{});
        };
        return loginVc;
    } else {
        IGWebLoginViewController *loginVc = [[IGWebLoginViewController alloc] init];
        loginVc.showCloseBtn = self.showCloseBtn;
        loginVc.beginGetUserInfoHandler = self.beginGetUserInfoHandler;
        loginVc.closeLoginPageHandler = self.closeLoginPageHandler;
        loginVc.authCompleteHandler = self.authCompleteHandler;
        loginVc.getUserInfoComplete = self.getUserInfoComplete;
        loginVc.loginComplete = ^(BOOL success, NSDictionary<NSString *,NSString *> * _Nonnull cookiesDict) {
            self.loginComplete(success, NO, @"", @{}, @"", cookiesDict);
        };
        return loginVc;
    }
}

+ (UIViewController *)loginViewControllerWithType:(IGLoginType)type {
    return [[self sharedInstance] loginViewControllerWithType:type];
}

@end
