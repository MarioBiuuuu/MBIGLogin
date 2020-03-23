#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class IGLInsFBLoginHelper;
@protocol IGLInsFBLoginHelperDelegate <NSObject>
@optional
- (void)fbLoginHelperLoginFinish:(IGLInsFBLoginHelper *)helper success:(BOOL)success checkPoint:(BOOL)checkPoint errorMessage:(NSString *)errorMessage loginUserDic:(NSDictionary *)loginUserDic cookie:(NSString *)cookie;
- (void)fbLoginHelperFetchUserInfoFinish:(IGLInsFBLoginHelper *)helper success:(BOOL)success errorMessage:(NSString *)errorMessage userDetailsDic:(NSDictionary *)userDetailsDic;
- (void)fbLoginHelperBeginLogin:(IGLInsFBLoginHelper *)helper;
- (void)fbLoginHelperBeginFetchUserInfo:(IGLInsFBLoginHelper *)helper;
@end
@interface IGLInsFBLoginHelper : NSObject
@property (nonatomic, copy) NSString *fbKey;
@property (nonatomic, weak, nullable) id <IGLInsFBLoginHelperDelegate> delegate;
+ (instancetype)sharedInstance;
- (void)handleFBLoginUrl:(NSURL *)url app:(UIApplication *)app options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;
@end
NS_ASSUME_NONNULL_END
