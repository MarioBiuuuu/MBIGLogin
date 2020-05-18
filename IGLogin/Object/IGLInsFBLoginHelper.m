#import "IGLInsFBLoginHelper.h"
#import "IGLInsRequest.h"
#import "IGLInsNotificationSet.h"
#import "IGLInsCommonHeader.h"
#import <Toast/Toast.h>
#import <MBProgressHUD/MBProgressHUD.h>
@implementation IGLInsFBLoginHelper
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}
- (NSString *)fbKey {
    if (!_fbKey) {
        _fbKey = @"124024574287414";
    }
    return _fbKey;
}
- (void)handleFBLoginUrl:(NSURL *)url app:(UIApplication *)app options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([url.scheme isEqualToString:[NSString stringWithFormat:@"fb%@", self.fbKey]]) {
        NSArray<NSString *> *params = [url.absoluteString componentsSeparatedByString:@"&"];
        if ([params.firstObject containsString:@"error="]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:IGLInsFBLoginCancelNotification_Login object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:IGLInsFBLoginSuccessNotification_Login object:nil];
            [self loginFBWithParams:params];
        }
    }
}
- (void)loginFBWithParams:(NSArray <NSString *> *)params {
    for (NSString *p in params) {
        if ([p containsString:@"access_token="]) {
            NSRange range = [p rangeOfString:@"="];
            NSString *token = [p substringFromIndex:range.location + 1];
            NSLog(@"%@", token);
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [MBProgressHUD showHUDAddedTo:DEF_Window animated:YES];
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(fbLoginHelperBeginLogin:)]) {
                    [strongSelf.delegate fbLoginHelperBeginLogin:strongSelf];
                }
            });
            [[IGLInsRequest sharedInstance] loginWithFacebook:token finished:^(BOOL success,BOOL checkPoint, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull facebookUserDict, NSString * _Nonnull cookie) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSDictionary *insUserInfoDict = @{}.copy;
                if (facebookUserDict) {
                    insUserInfoDict = facebookUserDict;
                }
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(fbLoginHelperLoginFinish:success:checkPoint:errorMessage:loginUserDic:cookie:)]) {
                    [strongSelf.delegate fbLoginHelperLoginFinish:strongSelf success:success checkPoint:checkPoint errorMessage:errorMessage loginUserDic:insUserInfoDict cookie:cookie];
                }
                if (success) {
                    if (facebookUserDict) {
                        [strongSelf getUserInfo:cookie userId:facebookUserDict[@"pk"] username:facebookUserDict[@"username"]];
                    } else {
                        [DEF_Window makeToast:NSLocalizedString(@"Get Instagram userinfo failed.", nil)];
                    }

                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:DEF_Window animated:YES];
                    });
                    if([errorMessage isEqualToString:@"checkpoint_required"] || [errorMessage containsString:@"challenge"]){
                        [DEF_Window makeToast:NSLocalizedString(@"Instagram want to confirm with your about your account privacy, so you need to login the actual instagram app, and then back to login again", nil)];
                    } else {
                        [DEF_Window makeToast:errorMessage];
                    }
                }
            }];
        }
    }
}
- (void)getUserInfo:(NSString *)cookie userId:(NSString *)userId username:(NSString *)username {
    NSString *csrftoken = @"";
    NSString *sessionID = @"";
    NSString *midString = @"";
    NSArray *subStrings = [cookie componentsSeparatedByString:@";"];
    for (NSString *theSubString in subStrings) {
        NSRange csrRange = [theSubString rangeOfString:@"csrftoken="];
        NSRange sessionRange = [theSubString rangeOfString:@"sessionid="];
        NSRange midRange = [theSubString rangeOfString:@"mid="];
        if(csrRange.length > 0){
            csrftoken = [theSubString substringWithRange:NSMakeRange(NSMaxRange(csrRange), theSubString.length - NSMaxRange(csrRange))];
        }
        if(sessionRange.length > 0){
            sessionID = [theSubString substringWithRange:NSMakeRange(NSMaxRange(sessionRange), theSubString.length - NSMaxRange(sessionRange))];
        }
        if(midRange.length > 0){
            midString = [theSubString substringWithRange:NSMakeRange(NSMaxRange(midRange), theSubString.length - NSMaxRange(midRange))];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(fbLoginHelperBeginFetchUserInfo:)]) {
        [self.delegate fbLoginHelperBeginFetchUserInfo:self];
    }
    __weak typeof(self) weakSelf = self;
    [[IGLInsRequest sharedInstance] getUserInfo:userId token:csrftoken user:username userId:userId mid:midString sessionId:sessionID finished:^(BOOL success, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull userDetailsDic) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:DEF_Window animated:YES];
        });
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(fbLoginHelperFetchUserInfoFinish:success:errorMessage:userDetailsDic:)]) {
            [strongSelf.delegate fbLoginHelperFetchUserInfoFinish:strongSelf success:success errorMessage:errorMessage userDetailsDic:userDetailsDic];
        }
    }];
}
@end
