//
/*******************************************************************************
    Copyright © 2020 Adrian. All rights reserved.

    File name:     IGLoginManager.h
    Author:        Adrian

    Project name:  GPInstagramLogin

    Description:
    

    History:
            2020/3/23: File created.

********************************************************************************/
    

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    IGLoginTypeAPI,
    IGLoginTypeWeb,
} IGLoginType;

@interface IGLoginManager : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *appstore_appId;
@property (nonatomic, copy) NSString *appstore_appName;
@property (nonatomic, assign) BOOL showCloseBtn;
@property (nonatomic, copy) void (^loginComplete)(BOOL success, BOOL checkPoint, NSString *errorMessage, NSDictionary *loginUserDic, NSString *cookie, NSDictionary <NSString *, NSString *> *cookiesDict);
@property (nonatomic, copy) void (^getUserInfoComplete)(BOOL success, NSString *errorMessage, NSDictionary *userDetailsDic);
@property (nonatomic, copy) void (^authCompleteHandler)(void);
@property (nonatomic, copy) void (^beginLoginHandler)(NSString *userName);
@property (nonatomic, copy) void (^beginGetUserInfoHandler)(void);
@property (nonatomic, copy) void (^loginIgnoreCheckPointHandler)(void);
@property (nonatomic, copy) void (^closeLoginPageHandler)(void);

- (UIViewController *)loginViewControllerWithType:(IGLoginType)type;
+ (UIViewController *)loginViewControllerWithType:(IGLoginType)type;
@end

NS_ASSUME_NONNULL_END
