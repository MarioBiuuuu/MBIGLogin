
    

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IGWebLoginViewController : UIViewController
@property (nonatomic, assign) BOOL showCloseBtn;
// 1
@property (nonatomic, copy) void (^loginComplete)(BOOL success, NSDictionary <NSString *, NSString *> *cookiesDict);
// 1
@property (nonatomic, copy) void (^getUserInfoComplete)(BOOL success, NSString *errorMessage, NSDictionary <NSString *, NSString *>*userDetailsDic);
// 1
@property (nonatomic, copy) void (^authCompleteHandler)(void);
// 1
@property (nonatomic, copy) void (^beginGetUserInfoHandler)(void);
// 1
@property (nonatomic, copy) void (^closeLoginPageHandler)(void);
@end

NS_ASSUME_NONNULL_END
