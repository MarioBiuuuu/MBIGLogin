#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface IGInsLoginViewController : UIViewController <WKScriptMessageHandler>
@property (nonatomic, assign) BOOL showCloseBtn;
@property (nonatomic, copy) void (^loginComplete)(BOOL success, BOOL checkPoint, NSString *errorMessage, NSDictionary *loginUserDic, NSString *cookie);
@property (nonatomic, copy) void (^getUserInfoComplete)(BOOL success, NSString *errorMessage, NSDictionary *userDetailsDic);
@property (nonatomic, copy) void (^authCompleteHandler)(void);
@property (nonatomic, copy) void (^beginLoginHandler)(NSString *userName);
@property (nonatomic, copy) void (^beginGetUserInfoHandler)(void);
@property (nonatomic, copy) void (^loginIgnoreCheckPointHandler)(void);
@property (nonatomic, copy) void (^closeLoginPageHandler)(void);
@end
NS_ASSUME_NONNULL_END
