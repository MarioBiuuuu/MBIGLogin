#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol IGLJavaScriptObjectiveCDelegate <JSExport>
- (void)callLoginWithDict:(NSDictionary *)params;
- (void)callForgetPassword;
- (void)callLoginWithFB;
@end
@class IGLInsJSObject;
@protocol IGLInsJSObjectDelegate <NSObject>
@optional
- (void)jsObject:(IGLInsJSObject *)jsObject loginWitUserName:(NSString *)name pwd:(NSString *)password;
- (void)jsObjectForgetPwd:(IGLInsJSObject *)jsObject;
- (void)jsObjectLoginWithFB:(IGLInsJSObject *)jsObject;
@end
@interface IGLInsJSObject : NSObject <IGLJavaScriptObjectiveCDelegate>
- (instancetype)initWithCallBackDelegate:(id <IGLInsJSObjectDelegate>)delegate;
@property (nonatomic, weak, nullable) id <IGLInsJSObjectDelegate> delegate;
@end
NS_ASSUME_NONNULL_END
