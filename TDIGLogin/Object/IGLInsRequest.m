#import "IGLInsRequest.h"
#include <sys/sysctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <netdb.h>
#import "NormalHelper.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <AdSupport/AdSupport.h>
#import <AFNetworking/AFNetworking.h>
static NSString *dp_ig_baseApi = @"https://i.instagram.com";
static NSString *dp_ig_definedKey = @"31daaa1bd12d53b039e0e21fe4214e6bb74ab2cd93854b48005bb4d1281ed405";
static NSTimeInterval dp_ig_maxTime = 60 * 1;
static NSInteger dp_ig_signKeyVersion = 5;
@implementation IGLInsRequest
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}
- (NSString *)userAgentString {
    NSString *currentIdentify = [[NSLocale currentLocale] localeIdentifier];
    NSString *languageIdentify = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *systemVersion = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSString *definedAgent = @"Instagram 121.0.0.29.119";
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    NSString *userAgent = @"";
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.61; 1080x1920; 171144701) AppleWebKit/420+", definedAgent, @"iPhone 7,1", UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
    } else {
        if ([platform isEqualToString:@"iPhone3,1"] || [platform isEqualToString:@"iPhone3,2"] || [platform isEqualToString:@"iPhone3,3"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 640x960; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone4,1"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 640x960; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone5,1"] || [platform isEqualToString:@"iPhone5,2"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 640x1136; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 640x1136; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 640x1136; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone7,2"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 750x1334; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone7,1"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.61; 1080x1920; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone8,1"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.61; 750x1334; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone8,2"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.61; 1080x1920; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone8,4"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 640x1136; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone9,1"] || [platform isEqualToString:@"iPhone9,3"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 750x1334; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone9,2"] || [platform isEqualToString:@"iPhone9,4"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.61; 1080x1920; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone10,1"] || [platform isEqualToString:@"iPhone10,4"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 750x1334; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone10,2"] || [platform isEqualToString:@"iPhone10,5"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.61; 1080x1920; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=3.00; 1125x2436; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone11,2"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=3.00; 1125x2436; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone11,4"] || [platform isEqualToString:@"iPhone11,6"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=3.00; 1242x2688; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"iPhone11,8"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.00; 828x1792; 171144701) AppleWebKit/420+", definedAgent, platform, UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]) {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.61; 1080x1920; 171144701) AppleWebKit/420+", definedAgent, @"iPhone 7,1", UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        } else {
            userAgent = [NSString stringWithFormat:@"%@(%@; %@ %@; %@; %@; scale=2.61; 1080x1920; 171144701) AppleWebKit/420+", definedAgent, @"iPhone 7,1", UIDevice.currentDevice.systemName, systemVersion, currentIdentify, languageIdentify];
        }
    }
    return userAgent;
}
- (void)loginWithFacebook:(NSString *)token finished:(void (^)(BOOL success,BOOL checkPoint, NSString *errorMessage, NSDictionary *facebookUserDict, NSString *cookie) )finishBlock {
    NSString *requestURL = [NSString stringWithFormat:@"%@/api/v1/fb/facebook_signup/", dp_ig_baseApi];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:dp_ig_maxTime];
    [request setHTTPMethod:@"POST"];
    NSString *deviceUDID = [[NSUUID UUID] UUIDString];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    NSString *content = [NSString stringWithFormat:@"{\"fb_access_token\":\"%@\",\"allow_contacts_sync\":\"%@\",\"device_id\":\"%@\",\"dryrun\":\"%@\",\"phone_id\":\"%@\",\"waterfall_id\":\"%@\"}", token, @"false", deviceUDID, @"true", deviceUDID, @"r1d3p85d2zb0tx8jrpy27ox3b23k2jty"];
    NSString *secretKey = [NormalHelper hmacsha1:content secret:dp_ig_definedKey];
    NSString *signedBody = [NSString stringWithFormat:@"%@.%@", secretKey, content];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithInteger:dp_ig_signKeyVersion] forKey:@"ig_sig_key_version"];
    [parameters setObject:signedBody forKey:@"signed_body"];
    NSString *sereParmeterString = [NormalHelper stringWithFormEncodedComponents:parameters];
    [request setHTTPBody:[sereParmeterString dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@", responseObject);
        if (!error) {
            NSString *metaCode = [responseObject objectForKey:@"status"];
            if([metaCode isEqualToString:@"ok"]){
                NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                NSDictionary *allHeaders = res.allHeaderFields;
                NSString *cookieDic = [allHeaders objectForKey:@"Set-Cookie"];
                NSDictionary *userInfo = [responseObject objectForKey:@"logged_in_user"];
                if (finishBlock) {
                    finishBlock(YES, NO, nil, userInfo, cookieDic);
                }
            }
        } else {
            NSString *errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSData *jsonData = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *resposeDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"Instagram Login Error = %@", resposeDic);
            NSString *errorMessage = [resposeDic objectForKey:@"message"] ? [resposeDic objectForKey:@"message"]: [error localizedDescription];
            if ([resposeDic[@"error_type"] isEqualToString:@"checkpoint_challenge_required"]) {
                if ([resposeDic.allKeys containsObject:@"checkpoint_url"]) {
                    NSArray *arr = [resposeDic[@"checkpoint_url"] componentsSeparatedByString:@"/challenge/"];
                    NSString *api = arr[1];
                    api = [NSString stringWithFormat:@"/challenge/%@", api];
                    finishBlock(NO, YES, api, nil, nil);
                } else if ([resposeDic.allKeys containsObject:@"challenge"]) {
                    finishBlock(NO, YES, [resposeDic[@"challenge"] objectForKey:@"api_path"], nil, nil);
                } else {
                    finishBlock(NO, NO, errorMessage, nil, nil);
                }
            } else {
                finishBlock(NO, NO, errorMessage, nil, nil);
            }
        }
    }];
    [task resume];
}
- (void)loginInstagram:(NSString *)username password:(NSString *)password complete:(void (^)(NSDictionary *loginUserDic, NSString *cookie) )completeBlock checkPointfailed:(void (^)(NSString *subApiUrlPath))checkPointfailedBlock twoFactorFailed:(void (^)(NSString *twoFactorIdentifier, NSString *userName, NSString *mobile, NSString *csrftoken) )twoFactorFailedBlock failed:(void (^)(NSString *errorMsg))failedBlock {
    NSString *requestURL = [NSString stringWithFormat:@"%@/api/v1/accounts/login/", dp_ig_baseApi];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:dp_ig_maxTime];
    [request setHTTPMethod:@"POST"];
    NSString *deviceUDID = [[NSUUID UUID] UUIDString];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"zh-hans" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"3brTPw==" forHTTPHeaderField:@"X-IG-Capabilities"];
    [request setValue:@"WIFI" forHTTPHeaderField:@"X-IG-Connection-Type"];
    [request setValue:@"Liger" forHTTPHeaderField:@"X-FB-HTTP-Engine"];
    [request setValue:@"i.instagram.com" forHTTPHeaderField:@"Host"];
    [request setValue:@"0" forHTTPHeaderField:@"X-FB-ABSURL-DEBUG"];
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    NSString *content = [NSString stringWithFormat:@"{\"username\":\"%@\",\"password\":\"%@\",\"guid\":\"%@\",\"device_id\":\"%@\",\"login_attempt_count\":0,\"phone_id\":\"%@\",\"adid\":\"%@\", \"csrftoken\":\"missing\"}", username, password, deviceUDID, [[UIDevice currentDevice].identifierForVendor UUIDString], [[UIDevice currentDevice].identifierForVendor UUIDString], [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    NSString *secretKey = [NormalHelper hmacsha1:content secret:dp_ig_definedKey];
    NSString *signedBody = [NSString stringWithFormat:@"%@.%@", secretKey, content];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithInteger:dp_ig_signKeyVersion] forKey:@"ig_sig_key_version"];
    [parameters setObject:signedBody forKey:@"signed_body"];
    NSString *sereParmeterString = [NormalHelper stringWithFormEncodedComponents:parameters];
    [request setHTTPBody:[sereParmeterString dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *metaCode = [responseObject objectForKey:@"status"];
            if([metaCode isEqualToString:@"ok"]){
                NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                NSDictionary *allHeaders = res.allHeaderFields;
                NSString *cookieDic = [allHeaders objectForKey:@"Set-Cookie"];
                NSDictionary *userInfo = [responseObject objectForKey:@"logged_in_user"];
                if (completeBlock) {
                    completeBlock(userInfo, cookieDic);
                }
            }
        } else {
            NSString *errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSData *jsonData = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *resposeDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"Instagram Login Error = %@", resposeDic);
            NSString *errorMessage = [resposeDic objectForKey:@"message"] ? [resposeDic objectForKey:@"message"]: [error localizedDescription];
            if ([resposeDic[@"error_type"] isEqualToString:@"checkpoint_challenge_required"]) {
                if ([resposeDic.allKeys containsObject:@"checkpoint_url"]) {
                    NSArray *arr = [resposeDic[@"checkpoint_url"] componentsSeparatedByString:@"/challenge/"];
                    NSString *api = arr[1];
                    api = [NSString stringWithFormat:@"/challenge/%@", api];
                    if (checkPointfailedBlock) {
                        checkPointfailedBlock(api);
                    }
                } else if ([resposeDic.allKeys containsObject:@"challenge"]) {
                    if (checkPointfailedBlock) {
                        checkPointfailedBlock([resposeDic[@"challenge"] objectForKey:@"api_path"]);
                    }
                } else {
                    if (failedBlock) {
                        failedBlock(errorMessage);
                    }
                }
            } else {
                BOOL isTwoFactor = [[responseObject objectForKey:@"two_factor_required"] boolValue];
                if (isTwoFactor) {
                    NSDictionary *userInfo = [responseObject objectForKey:@"two_factor_info"];
                    if (twoFactorFailedBlock) {
                        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                        NSDictionary *allHeaders = res.allHeaderFields;
                        NSString *cookieDic = [allHeaders objectForKey:@"Set-Cookie"];
                        NSString *csrftoken = @"";
                        NSArray *subStrings = [cookieDic componentsSeparatedByString:@";"];
                        for (NSString *theSubString in subStrings) {
                            NSRange csrRange = [theSubString rangeOfString:@"csrftoken="];
                            if(csrRange.length > 0){
                                csrftoken = [theSubString substringWithRange:NSMakeRange(NSMaxRange(csrRange), theSubString.length - NSMaxRange(csrRange))];
                            }
                        }
                        twoFactorFailedBlock(userInfo[@"two_factor_identifier"], userInfo[@"username"], userInfo[@"obfuscated_phone_number"], csrftoken);
                    }
                } else {
                    if ([errorMessage isEqualToString:@"challenge_required"]) {
                        if (failedBlock) {
                            NSString *e = [NSString stringWithFormat:@"It looks like you shared your password with a service to help you g%@re li%@owers, which goes against Inst%@unity Guidelines.Change your password to continue usi%@gram. If you share your new password with one of these services, you may get bl%@lowing, li%@enting.", @"et mo", @"kes or foll", @"agram Comm", @"ng Insta", @"ocked from fol", @"king or comm"];
                            failedBlock(e);
                        }
                    } else {
                        if (failedBlock) {
                            failedBlock(errorMessage);
                        }
                    }
                }
            }
        }
    }];
    [task resume];
}
- (void)getUserInfo:(NSString *)userID token:(NSString *)token user:(NSString *)user userId:(NSString *)user_id mid:(NSString *)mid sessionId:(NSString *)sessionId finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *userDetailsDic) )finishBlock
{
    NSString *requestURL = [NSString stringWithFormat:@"%@/api/v1/users/%@/info/", dp_ig_baseApi, userID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:dp_ig_maxTime];
    [request setHTTPMethod:@"GET"];
    [request setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (countryCode != nil) {
        [cookieDic setObject:countryCode forKey:@"ccode"];
    }
    [cookieDic setObject:token?:@"missing" forKey:@"csrftoken"];
    [cookieDic setObject:user?:@"" forKey:@"ds_user"];
    [cookieDic setObject:user_id?:@"" forKey:@"ds_user_id"];
    if(mid)
        [cookieDic setObject:mid?:@"" forKey:@"mid"];
    [cookieDic setObject:sessionId?:@"" forKey:@"sessionid"];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieDic];
    NSArray* cookieArray = [NSArray arrayWithObjects: cookie, nil];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPShouldHandleCookies:YES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *metaCode = [responseObject objectForKey:@"status"];
            if([metaCode isEqualToString:@"ok"]){
                NSDictionary *userInfo = [responseObject objectForKey:@"user"];
                finishBlock(YES, nil, userInfo);
            }
        } else {
            NSString *errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSData *jsonData = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *resposeDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"Instagram Get User Info Error = %@", resposeDic);
            NSString *errorMessage = [resposeDic objectForKey:@"message"];
            if ([errorMessage isEqualToString:@"consent_required"]) {
                if ([resposeDic.allKeys containsObject:@"consent_data"]) {
                    NSDictionary *dict = resposeDic[@"consent_data"];
                    NSString *content = dict[@"content"];
                    finishBlock(NO, content,nil);
                } else {
                    finishBlock(NO, errorMessage,nil);
                }
            } else {
                finishBlock(NO, errorMessage,nil);
            }
        }
    }];
    [task resume];
}
- (void)getChallengeRequiredDataWithSubApi:(NSString *)subApi finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *challengeDict, NSString *subApi) )finishBlock{
    NSString *deviceUDID = [[NSUUID UUID] UUIDString];
    NSString *requestURL = [NSString stringWithFormat:@"%@/api/v1%@?device_id=%@", dp_ig_baseApi, subApi, deviceUDID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:dp_ig_maxTime];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *metaCode = [responseObject objectForKey:@"status"];
            if([metaCode isEqualToString:@"ok"]){
                finishBlock(YES, nil, responseObject, subApi);
            }
        } else {
            NSString *errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSData *jsonData = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *resposeDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"Instagram Get User Info Error = %@", resposeDic);
            NSString *errorMessage = [resposeDic objectForKey:@"message"];
            finishBlock(NO, errorMessage,nil, subApi);
        }
    }];
    [task resume];
}
- (void)getVerifyCode:(NSString *)choice subApi:(NSString *)subApi finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *verifyDict, NSString *subApi) )finishBlock{
    NSString *deviceUDID = [[NSUUID UUID] UUIDString];
    NSString *requestURL = [NSString stringWithFormat:@"%@/api/v1%@", dp_ig_baseApi, subApi];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:dp_ig_maxTime];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    NSString *content = [NSString stringWithFormat:@"{\"choice\":\"%@\",\"device_id\":\"%@\"}", choice, deviceUDID];
    NSString *secretKey = [NormalHelper hmacsha1:content secret:dp_ig_definedKey];
    NSString *signedBody = [NSString stringWithFormat:@"%@.%@", secretKey, content];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithInteger:dp_ig_signKeyVersion] forKey:@"ig_sig_key_version"];
    [parameters setObject:signedBody forKey:@"signed_body"];
    NSString *sereParmeterString = [NormalHelper stringWithFormEncodedComponents:parameters];
    [request setHTTPBody:[sereParmeterString dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *metaCode = [responseObject objectForKey:@"status"];
            if([metaCode isEqualToString:@"ok"]){
                if (finishBlock) {
                    finishBlock(YES, nil, responseObject, subApi);
                }
            }
        } else {
            NSString *errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSData *jsonData = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *resposeDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"Instagram Login Error = %@", resposeDic);
            NSString *errorMessage = [resposeDic objectForKey:@"message"] ? [resposeDic objectForKey:@"message"]: [error localizedDescription];
            if (finishBlock) {
                finishBlock(NO, errorMessage, nil, subApi);
            }
        }
    }];
    [task resume];
}
- (void)verifyCode:(NSString *)code subApi:(NSString *)subApi finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *loginUserDic, NSString *cookie) )finishBlock {
    NSString *deviceUDID = [[NSUUID UUID] UUIDString];
    NSString *requestURL = [NSString stringWithFormat:@"%@/api/v1%@", dp_ig_baseApi, subApi];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:dp_ig_maxTime];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    NSString *content = [NSString stringWithFormat:@"{\"security_code\":\"%@\",\"device_id\":\"%@\"}", code, deviceUDID];
    NSString *secretKey = [NormalHelper hmacsha1:content secret:dp_ig_definedKey];
    NSString *signedBody = [NSString stringWithFormat:@"%@.%@", secretKey, content];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithInteger:dp_ig_signKeyVersion] forKey:@"ig_sig_key_version"];
    [parameters setObject:signedBody forKey:@"signed_body"];
    NSString *sereParmeterString = [NormalHelper stringWithFormEncodedComponents:parameters];
    [request setHTTPBody:[sereParmeterString dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *metaCode = [responseObject objectForKey:@"status"];
            if([metaCode isEqualToString:@"ok"]){
                NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                NSDictionary *allHeaders = res.allHeaderFields;
                NSString *cookieDic = [allHeaders objectForKey:@"Set-Cookie"];
                NSDictionary *userInfo = [responseObject objectForKey:@"logged_in_user"];
                if (userInfo) {
                    if (finishBlock) {
                        finishBlock(YES, nil, userInfo, cookieDic);
                    }
                } else {
                    finishBlock(NO, NSLocalizedString(@"Verification succeeded. Please enter your user name and log in again.", nil), nil, nil);
                }
            }
        } else {
            NSString *errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSData *jsonData = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *resposeDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"Instagram Login Error = %@", resposeDic);
            NSString *errorMessage = [resposeDic objectForKey:@"message"] ? [resposeDic objectForKey:@"message"]: [error localizedDescription];
            if (finishBlock) {
                finishBlock(NO, errorMessage, nil, nil);
            }
        }
    }];
    [task resume];
}
- (void)verifyTwoFactorCode:(NSString *)code two_factor_identifier:(NSString *)two_factor_identifier username:(NSString *)username csrftoken:(NSString *)csrftoken finished:(void (^)(BOOL success, NSString *errorMessage, NSDictionary *loginUserDic, NSString *cookie) )finishBlock {
    NSString *deviceUDID = [[NSUUID UUID] UUIDString];
    NSString *requestURL = [NSString stringWithFormat:@"%@/api/v1%@", dp_ig_baseApi, @"/accounts/two_factor_login/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:dp_ig_maxTime];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    NSString *content = [NSString stringWithFormat:@"{\"_csrftoken\":\"%@\",\"device_id\":\"%@\",\"guid\":\"%@\",\"two_factor_identifier\":\"%@\",\"username\":\"%@\",\"verification_code\":\"%@\"}", csrftoken, [[UIDevice currentDevice].identifierForVendor UUIDString], deviceUDID, two_factor_identifier, username, code];
    NSString *secretKey = [NormalHelper hmacsha1:content secret:dp_ig_definedKey];
    NSString *signedBody = [NSString stringWithFormat:@"%@.%@", secretKey, content];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSNumber numberWithInteger:dp_ig_signKeyVersion] forKey:@"ig_sig_key_version"];
    [parameters setObject:signedBody forKey:@"signed_body"];
    NSString *sereParmeterString = [NormalHelper stringWithFormEncodedComponents:parameters];
    [request setHTTPBody:[sereParmeterString dataUsingEncoding:NSUTF8StringEncoding]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *metaCode = [responseObject objectForKey:@"status"];
            if([metaCode isEqualToString:@"ok"]){
                NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                NSDictionary *allHeaders = res.allHeaderFields;
                NSString *cookieDic = [allHeaders objectForKey:@"Set-Cookie"];
                NSDictionary *userInfo = [responseObject objectForKey:@"logged_in_user"];
                if (userInfo) {
                    if (finishBlock) {
                        finishBlock(YES, nil, userInfo, cookieDic);
                    }
                } else {
                    finishBlock(NO, NSLocalizedString(@"Verification succeeded. Please enter your user name and log in again.", nil), nil, nil);
                }
            }
        } else {
            NSString *errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSData *jsonData = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *resposeDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"Instagram Login Error = %@", resposeDic);
            NSString *errorMessage = [resposeDic objectForKey:@"message"] ? [resposeDic objectForKey:@"message"]: [error localizedDescription];
            if (finishBlock) {
                finishBlock(NO, errorMessage, nil, nil);
            }
        }
    }];
    [task resume];
}
- (void)getIGUserDetailWithUserID:(NSString *)userID completion: (void (^)(BOOL success, NSString *errorMessage, NSDictionary *userDetailsDic) )finishBlock {
    NSString *requestURL = [NSString stringWithFormat:@"%@/api/v1/users/%@/info/", dp_ig_baseApi, userID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:dp_ig_maxTime];
    [request setHTTPMethod:@"GET"];
    // set User-Agent
    [request setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSString *metaCode = [responseObject objectForKey:@"status"];
            if([metaCode isEqualToString:@"ok"]){
                NSDictionary *userInfo = [responseObject objectForKey:@"user"];
                NSMutableDictionary *userInfoDict_M = @{}.mutableCopy;
                
                for (NSString *key in userInfo.allKeys) {
                    id value = userInfo[key];
                    if ([value isKindOfClass:[NSString class]]) {
                        [userInfoDict_M setValue:value forKey:key];
                        [userInfoDict_M setValue:value forKey:key];
                    } else {
  
                    }
                    
                }
                
                finishBlock(YES, nil, userInfoDict_M);
            }
        } else {
            NSString *errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSData *jsonData = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *resposeDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSLog(@"Instagram Get User Info Error = %@", resposeDic);
            NSString *errorMessage = [resposeDic objectForKey:@"message"];

            if ([errorMessage isEqualToString:@"consent_required"]) {
                if ([resposeDic.allKeys containsObject:@"consent_data"]) {
                    NSDictionary *dict = resposeDic[@"consent_data"];
                    NSString *content = dict[@"content"];
                    finishBlock(NO, content,nil);
                } else {
                    finishBlock(NO, errorMessage,nil);
                }
            } else {
                finishBlock(NO, errorMessage,nil);
            }
        }
    }];
    [task resume];
}

@end
