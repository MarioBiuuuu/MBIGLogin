#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface IGLInsRequest : NSObject
+ (instancetype)sharedInstance;
- (void)loginWithFacebook:(NSString *)token finished:(void (^)(BOOL success,BOOL checkPoint, NSString *errorMessage, NSDictionary *facebookUserDict, NSString *cookie) )finishBlock;
- (void)loginInstagram:(NSString *)username password:(NSString *)password complete:(void (^)(NSDictionary *loginUserDic, NSString *cookie) )completeBlock checkPointfailed:(void (^)(NSString *subApiUrlPath))checkPointfailedBlock twoFactorFailed:(void (^)(NSString *twoFactorIdentifier, NSString *userName, NSString *mobile, NSString *csrftoken) )twoFactorFailedBlock failed:(void (^)(NSString *errorMsg))failedBlock;
- (void)getUserInfo:(NSString *)userID token:(NSString *)token user:(NSString *)user userId:(NSString *)user_id mid:(NSString *)mid sessionId:(NSString *)sessionId finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *userDetailsDic) )finishBlock;
- (void)getChallengeRequiredDataWithSubApi:(NSString *)subApi finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *challengeDict, NSString *subApi) )finishBlock;
- (void)getVerifyCode:(NSString *)choice subApi:(NSString *)subApi finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *verifyDict, NSString *subApi) )finishBlock;
- (void)verifyCode:(NSString *)code subApi:(NSString *)subApi finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *loginUserDic, NSString *cookie) )finishBlock;
- (void)verifyTwoFactorCode:(NSString *)code two_factor_identifier:(NSString *)two_factor_identifier username:(NSString *)username csrftoken:(NSString *)csrftoken finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *loginUserDic, NSString *cookie) )finishBlock;
- (void)getIGUserDetailWithUserID:(NSString *)userID completion: (void (^)(BOOL success, NSString *errorMessage, NSDictionary *userDetailsDic) )finishBlock;
@end
NS_ASSUME_NONNULL_END
