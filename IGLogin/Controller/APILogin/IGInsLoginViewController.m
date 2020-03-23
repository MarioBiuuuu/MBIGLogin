#import "IGInsLoginViewController.h"
#import "IGLInsJSObject.h"
#import "IGLInsRequest.h"
#import "IGLInsCommonHeader.h"
#import "IGLInsFBLoginViewController.h"
#import "IGLInsLoginChallengeView.h"
#import "IGLInsLoginVerifyCodeView.h"
#import "IGLInsTwoFactorLoginView.h"
#import "IGInsLoginTopView.h"
#import "GPCPWebMessage.h"
#import "IGLoginManager.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>
#import <WebKit/WebKit.h>
#import "IGLInsFBLoginHelper.h"


@interface IGInsLoginViewController () <WKNavigationDelegate, WKUIDelegate, IGLInsJSObjectDelegate>
@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) IGInsLoginTopView *topView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) IGLInsJSObject *jsObject;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *loginUserName;
@property (nonatomic, copy) NSString *loginPassword;
@property (nonatomic, assign) NSInteger checkpointTotalCount;
@property (nonatomic, strong) IGLInsLoginChallengeView *challengeView;
@property (nonatomic, strong) IGLInsLoginVerifyCodeView *codeView;
@property (nonatomic, strong) IGLInsTwoFactorLoginView *twoFactorLoginView;
@property (nonatomic, strong) UIView *checkPointBgView;
@end
@implementation IGInsLoginViewController
#pragma mark -
#pragma mark - LifeCyle
- (void)dealloc {
    NSLog(@" %@ - 释放了 ", self.class);
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"InsLoginHandler"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [IGLInsFBLoginHelper sharedInstance].delegate = self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    self.checkpointTotalCount = 0;
    NSString *appName = [IGLoginManager sharedInstance].appstore_appName.length > 0 ? [IGLoginManager sharedInstance].appstore_appName : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *tip = [NSString stringWithFormat:@"%@ never sees or stores your Instagram password.", appName];
    self.tipLab.text = tip;
    [self clearWebCache];
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
#pragma mark -
#pragma mark - Intial Methods
- (void)clearWebCache {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}
- (void)initialUI {
    self.view.backgroundColor = [UIColor colorWithRed:23.0 / 255.0 green:24.0 / 255.0 blue:52.0 / 255.0 alpha:1];
    [self initialSubViews];
    [self.topView setNeedShowClose:self.showCloseBtn];
}
- (void)initialSubViews {
    __weak typeof(self) weakSelf = self;
    [self.topView setCloaseAction:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
       [strongSelf closeLoginPage];
    }];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.tipView];
    [self.tipView addSubview:self.tipLab];
    NSString *indexPagePath = DEF_Name(@"login.html");
    NSURL *url = [NSURL fileURLWithPath:indexPagePath];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}
#pragma mark -
#pragma mark - lazy load
- (IGInsLoginTopView *)topView {
    if (!_topView) {
        _topView = [[NSBundle bundleWithPath: DEF_BundlePath] loadNibNamed:@"IGInsLoginTopView" owner:nil options:nil].firstObject;
        _topView.frame = CGRectMake(0, k_Height_StatusBar, DEF_SCREEN_WIDTH, 44);
    }
    return _topView;
}
- (IGLInsTwoFactorLoginView *)twoFactorLoginView {
    if (!_twoFactorLoginView) {
        _twoFactorLoginView = [[NSBundle bundleWithPath: DEF_BundlePath] loadNibNamed:@"IGLInsTwoFactorLoginView" owner:nil options:nil].firstObject;
        _twoFactorLoginView.frame = self.view.bounds;
    }
    return _twoFactorLoginView;
}
- (IGLInsLoginChallengeView *)challengeView {
    if (!_challengeView) {
        _challengeView = [[NSBundle bundleWithPath: DEF_BundlePath] loadNibNamed:@"IGLInsLoginChallengeView" owner:nil options:nil].firstObject;
        _challengeView.frame = self.view.bounds;
    }
    return _challengeView;
}
- (IGLInsLoginVerifyCodeView *)codeView {
    if (!_codeView) {
        _codeView = [[NSBundle bundleWithPath: DEF_BundlePath] loadNibNamed:@"IGLInsLoginVerifyCodeView" owner:nil options:nil].firstObject;
        _codeView.frame = self.view.bounds;
    }
    return _codeView;
}
- (UIView *)checkPointBgView {
    if (!_checkPointBgView) {
        _checkPointBgView = [[UIView alloc] initWithFrame:self.view.bounds];
        _checkPointBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _checkPointBgView;
}
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - k_Height_StatusBar - DEF_SafeAreaBottom - 70 - 44);
        _webView.backgroundColor = [UIColor colorWithRed:250.0 / 255.0 green:250.0 / 255.0 blue:250.0 / 255.0 alpha:1];
        _webView.navigationDelegate = self;
        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"InsLoginHandler"];
    }
    return _webView;
}
- (UIView *)tipView {
    if (!_tipView) {
        _tipView = [[UIView alloc] init];
        _tipView.frame = CGRectMake(0, CGRectGetMaxY(self.webView.frame), UIScreen.mainScreen.bounds.size.width, 70 + DEF_SafeAreaBottom);
        _tipView.backgroundColor = [UIColor colorWithRed:23.0 / 255.0 green:24.0 / 255.0 blue:52.0 / 255.0 alpha:1];
    }
    return _tipView;
}
- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, UIScreen.mainScreen.bounds.size.width - 40, 70)];
        _tipLab.numberOfLines = 2;
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.font = [UIFont systemFontOfSize:13.f];
        _tipLab.textColor = [UIColor whiteColor];
    }
    return _tipLab;
}

#pragma mark -
#pragma mark - Target Methods
- (void)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark - Private Method
- (void)showLoginFbPage {
    IGLInsFBLoginViewController *vc = [[IGLInsFBLoginViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    vc.beginLoginHandler = self.beginLoginHandler;
    vc.beginGetUserInfoHandler = self.beginGetUserInfoHandler;
    vc.loginComplete = ^(BOOL success, BOOL checkPoint, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull loginUserDic, NSString * _Nonnull cookie) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (self.loginComplete) {
            self.loginComplete(success, checkPoint, errorMessage, loginUserDic, cookie);
        }
        if (!success) {
            if (checkPoint) {
                [self checkChallenge:errorMessage];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                });
                if([errorMessage isEqualToString:@"checkpoint_required"]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.view makeToast:NSLocalizedString(@"Instagram want to confirm with your about your account privacy, so you need to login the actual instagram app, and then back to login again", nil) duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.view makeToast:errorMessage duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
                    });
                }
            }
        }
    };
    vc.getUserInfoComplete = ^(BOOL success, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull userDetailsDic) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (self.getUserInfoComplete) {
            self.getUserInfoComplete(success, errorMessage, userDetailsDic);
        }
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf closeLoginPage];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.view makeToast:errorMessage duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
            });
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
- (BOOL)firstAuthenticationUser:(NSString *)userId {
    NSString *authenKey = [NSString stringWithFormat:@"hasAuthenticationInThisDevice_%@", userId];
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:authenKey]){
        return YES;
    }else{
        return NO;
    }
}
- (void)loginInstagram:(NSString *)userName password:(NSString *)password {
    if (userName.length > 0) {
        self.loginUserName = userName;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"invalid username." duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
        });
        return;
    }
    if (password.length > 0) {
        self.loginPassword = password;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"invalid password." duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
        });
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
        if (self.beginLoginHandler) {
            self.beginLoginHandler(userName);
        }
    });
    [[IGLInsRequest sharedInstance] loginInstagram:userName password:password complete:^(NSDictionary * _Nonnull loginUserDic, NSString * _Nonnull cookie) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.userId = [loginUserDic objectForKey:@"pk"];
        strongSelf.userName = loginUserDic[@"username"];
        [strongSelf appSessionRequest:YES userId: [loginUserDic objectForKey:@"pk"] userDic:loginUserDic cookie:cookie];
        if (self.loginComplete) {
            self.loginComplete(YES, NO, @"", loginUserDic, cookie);
        }
    } checkPointfailed:^(NSString * _Nonnull subApiUrlPath) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf checkChallenge:subApiUrlPath];
        if (self.loginComplete) {
            self.loginComplete(NO, YES, @"", nil, nil);
        }
    } twoFactorFailed:^(NSString * _Nonnull twoFactorIdentifier, NSString * _Nonnull userName, NSString *mobile, NSString *csrftoken) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        [strongSelf showTwoFactorLoginViewWithTwoFactorCodeIdentifier:twoFactorIdentifier userName:userName mobile:mobile csrftoken:csrftoken];
        if (self.loginComplete) {
            self.loginComplete(NO, NO, @"", nil, nil);
        }
    } failed:^(NSString * _Nonnull errorMsg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (self.loginComplete) {
            self.loginComplete(NO, NO, errorMsg, nil, nil);
        }
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        if([errorMsg isEqualToString:@"checkpoint_required"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.view makeToast:NSLocalizedString(@"Instagram want to confirm with your about your account privacy, so you need to login the actual instagram app, and then back to login again", nil) duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.view makeToast:errorMsg  duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
            });
        }
    }];
}
- (void)appSessionRequest:(BOOL)isLogin userId:(NSString *)userId userDic:(NSDictionary *)userDic cookie:(NSString *)cookie {
    __weak typeof(self) weakSelf = self;
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
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (self.beginGetUserInfoHandler) {
        self.beginGetUserInfoHandler();
    }
    [[IGLInsRequest sharedInstance] getUserInfo:userId token:csrftoken user:userDic[@"username"] userId:userDic[@"pk"] mid:midString sessionId:sessionID finished:^(BOOL success, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull userDetailsDic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        });
        if (self.getUserInfoComplete) {
            self.getUserInfoComplete(success, errorMessage, userDetailsDic);
        }
        if (success) {
            if ([strongSelf firstAuthenticationUser:userId]) {
                [strongSelf showAuthenticationPage];
            } else {
                [strongSelf closeLoginPage];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.view makeToast:errorMessage duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
            });
        }
    }];
}
- (void)checkChallenge:(NSString *)apiPath {
    __weak typeof(self) weakSelf = self;
    [[IGLInsRequest sharedInstance] getChallengeRequiredDataWithSubApi:apiPath finished:^(BOOL success, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull challengeDict, NSString * _Nonnull subApi) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (success) {
            if ([challengeDict[@"step_name"] isEqualToString:@"verify_code"]) {
                NSDictionary *stepData = challengeDict[@"step_data"];
                NSString *tip = @"";
                NSString *type = @"0";
                tip = [NSString stringWithFormat:@"Enter the 6-digit code we sent to the phone %@", stepData[@"phone_number_formatted"]];
                [strongSelf showInputVerifyCodeView:tip apiPath:apiPath verifyType:type];
            } else if ([challengeDict[@"step_name"] isEqualToString:@"verify_email"]) {
                NSDictionary *stepData = challengeDict[@"step_data"];
                NSString *tip = @"";
                NSString *type = @"1";
                tip = [NSString stringWithFormat:@"Enter the 6-digit code we sent to the email address %@", stepData[@"contact_point"]];
                [strongSelf showInputVerifyCodeView:tip apiPath:apiPath verifyType:type];
            } else if ([challengeDict[@"step_name"] isEqualToString:@"submit_phone"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [strongSelf.view makeToast:@"Please go to Instagram and submit your phone." duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
                });
            } else {
                if ([challengeDict.allKeys containsObject:@"step_data"]) {
                    NSString *email = @"";
                    NSString *mobile = @"";
                    NSDictionary *stepData = challengeDict[@"step_data"];
                    if ([stepData.allKeys containsObject:@"email"]) {
                        email = stepData[@"email"];
                    }
                    if ([stepData.allKeys containsObject:@"phone_number"]) {
                        mobile = stepData[@"phone_number"];
                    }
                    [strongSelf showChallengeView:apiPath email:email mobile:mobile];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.view makeToast:@"Unexpected login error happened, please try again later." duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
                    });
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                [strongSelf.view makeToast:errorMessage duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
            });
        }
    }];
}
- (void)showChallengeView:(NSString *)apiPath email:(NSString *)email mobile:(NSString *)mobile {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    if (email.length > 0) {
        [self.challengeView.emailBtn setTitle:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Email", nil), email] forState:UIControlStateNormal];
        self.challengeView.emailHeight.constant = 30.f;
        self.challengeView.mobileTop.constant = 5;
        self.challengeView.emailBtn.hidden = NO;
        self.challengeView.emailBtn.selected = YES;
        self.challengeView.mobileBtn.selected = NO;
    } else {
        self.challengeView.emailHeight.constant = 0.f;
        self.challengeView.mobileTop.constant = 0.f;
        self.challengeView.emailBtn.hidden = YES;
        self.challengeView.emailBtn.selected = NO;
        self.challengeView.mobileBtn.selected = YES;
    }
    if (mobile.length > 0) {
        [self.challengeView.mobileBtn setTitle:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Phone", nil), mobile] forState:UIControlStateNormal];
        self.challengeView.mobileHeight.constant = 30.f;
        self.challengeView.mobileBtn.hidden = NO;
    } else {
        self.challengeView.mobileHeight.constant = 0.f;
        self.challengeView.mobileTop.constant = 0.f;
        self.challengeView.mobileBtn.hidden = YES;
    }
    [self.view addSubview:self.checkPointBgView];
    __weak typeof(self) weakSelf = self;
    [self.challengeView setSendActionClick:^(NSString * _Nonnull type) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf getVerifyCode:apiPath verifyType:type completion:^(BOOL success) {
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *tip = @"";
            if ([type integerValue] == 0) {
                tip = [NSString stringWithFormat:@"Enter the 6-digit code we sent to the phone %@", mobile];
            } else {
                tip = [NSString stringWithFormat:@"Enter the 6-digit code we sent to the email address %@", email];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.challengeView removeFromSuperview];
            });
            [strongSelf showInputVerifyCodeView:tip apiPath:apiPath verifyType:type];
        });
    }];
    [self.challengeView setCloseClick:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.challengeView removeFromSuperview];
            [strongSelf.checkPointBgView removeFromSuperview];
        });
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.challengeView];
    });
}
- (void)showInputVerifyCodeView:(NSString *)tipMsg apiPath:(NSString *)apiPath verifyType:(NSString *)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    self.codeView.tipLab.text = tipMsg;
    [self.codeView.tv clearCode];
    __weak typeof(self) weakSelf = self;
    [self.codeView setOkActionHandler:^(NSString * _Nonnull code) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.codeView removeFromSuperview];
            [strongSelf.checkPointBgView removeFromSuperview];
        });
        [strongSelf verifyCode:code subApi:apiPath];
    }];
    [self.codeView setCloseClick:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.codeView removeFromSuperview];
            [strongSelf.checkPointBgView removeFromSuperview];
        });
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.codeView];
    });
}
- (void)getVerifyCode:(NSString *)apiPath verifyType:(NSString *)type completion:(void(^)(BOOL success))completion {
    __weak typeof(self) weakSelf = self;
    [[IGLInsRequest sharedInstance] getVerifyCode:type subApi:apiPath finished:^(BOOL success, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull verifyDict, NSString * _Nonnull subApi) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (completion) {
            completion(success);
        }
        if (success) {
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.view makeToast:errorMessage duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
            });
        }
    }];
}
- (void)verifyCode:(NSString *)code subApi:(NSString *)subApi {
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[IGLInsRequest sharedInstance] verifyCode:code subApi:subApi finished:^(BOOL success, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull loginUserDic, NSString * _Nonnull cookie) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        });
        if (self.loginComplete) {
            self.loginComplete(success, NO, errorMessage, loginUserDic, cookie);
        }
        if (success) {
            if (loginUserDic) {
                strongSelf.userId = [loginUserDic objectForKey:@"pk"];
                strongSelf.userName = loginUserDic[@"username"];
                [strongSelf appSessionRequest:YES userId: [loginUserDic objectForKey:@"pk"] userDic:loginUserDic cookie:cookie];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{

                    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Verification succeeded. Please enter your user name and log in again.", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [alerController addAction:okAction];
                    [self presentViewController:alerController animated:YES completion:nil];
                    
                });
            }
        } else {
            UIAlertController *alerController = [UIAlertController alertControllerWithTitle:nil message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alerController addAction:okAction];
            [self presentViewController:alerController animated:YES completion:nil];
        }
    }];
}
- (void)verifyTwoFactorCode:(NSString *)twoFactorCode twoFactorCodeIdentifier:(NSString *)twoFactorIndetifier userName:(NSString *)userName csrftoken:(NSString *)csrftoken {
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[IGLInsRequest sharedInstance] verifyTwoFactorCode:twoFactorCode two_factor_identifier:twoFactorIndetifier username:userName csrftoken:csrftoken finished:^(BOOL success, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull loginUserDic, NSString * _Nonnull cookie) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        });
        if (self.loginComplete) {
            self.loginComplete(success, NO, errorMessage, loginUserDic, cookie);
        }
        if (success) {
            if (loginUserDic) {
                strongSelf.userId = [loginUserDic objectForKey:@"pk"];
                strongSelf.userName = loginUserDic[@"username"];
                [strongSelf appSessionRequest:YES userId: [loginUserDic objectForKey:@"pk"] userDic:loginUserDic cookie:cookie];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Verification succeeded. Please enter your user name and log in again.", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [alerController addAction:okAction];
                    [self presentViewController:alerController animated:YES completion:nil];
                });
            }
        } else {
            UIAlertController *alerController = [UIAlertController alertControllerWithTitle:nil message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alerController addAction:okAction];
            [self presentViewController:alerController animated:YES completion:nil];
        }
    }];
}
- (void)showTwoFactorLoginViewWithTwoFactorCodeIdentifier:(NSString *)twoFactorIndetifier userName:(NSString *)userName mobile:(NSString *)mobile csrftoken:(NSString *)csrftoken {
    [self.view addSubview:self.checkPointBgView];
    self.twoFactorLoginView.codeTF.text = @"";
    __weak typeof(self) weakSelf = self;
    [self.twoFactorLoginView setOkActionHandler:^(NSString * _Nonnull code) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.twoFactorLoginView removeFromSuperview];
            [strongSelf.checkPointBgView removeFromSuperview];
        });
        [strongSelf verifyTwoFactorCode:code twoFactorCodeIdentifier:twoFactorIndetifier userName:userName csrftoken:csrftoken];
    }];
    [self.twoFactorLoginView setCloseClick:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.twoFactorLoginView removeFromSuperview];
            [strongSelf.checkPointBgView removeFromSuperview];
        });
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.twoFactorLoginView];
    });
}
- (void)showAuthenticationPage {
    NSString *pagePath = DEF_Name(@"detail.html");
    NSURL *authUrl = [NSURL fileURLWithPath:pagePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:authUrl];
    [self.webView loadRequest:request];
}
- (void)handleQuery:(NSString *)queryName value:(NSString *)queryValue {
    if ([queryName isEqualToString:@"allow"]) {
        if ([queryValue isEqualToString:@"Authorize"]) {
            [self finishAuthorization];
        }
        else if ([queryValue isEqualToString:@"Cancel"]) {
            [self cancelAuthorization];
        }
    }
}
- (NSArray *)queryArrayFromQueryStrings:(NSString *)queryString {
    NSMutableArray *queryArray = [NSMutableArray array];
    for (NSString *queryComponent in [queryString componentsSeparatedByString:@"&"]) {
        NSString *queryName = @"";
        NSString *queryValue = @"";
        NSRange range = [queryComponent rangeOfString:@"="];
        if (range.location == NSNotFound) {
            queryName = queryComponent;
        } else {
            queryName = [queryComponent substringWithRange:NSMakeRange(0, range.location)];
            queryValue = [queryComponent substringFromIndex:range.location + range.length];
            queryValue = [queryValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [queryArray addObject:@{@"name": queryName, @"value": queryValue}];
    }
    return [NSArray arrayWithArray:queryArray];
}
- (void)cancelAuthorization {
    NSString *indexPagePath = DEF_Name(@"login.html");
    NSURL *url = [NSURL fileURLWithPath:indexPagePath];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}
- (void)finishAuthorization {
    NSString *authenKey = [NSString stringWithFormat:@"hasAuthenticationInThisDevice_%@", self.userId];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:authenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.authCompleteHandler) {
            self.authCompleteHandler();
        }
        [self closeLoginPage];
    });
}
- (void)displayLoginErrorMessage:(NSString *)errorMessage {
    NSString *jsString = [NSString stringWithFormat:@"LoginError('%@'); UsernameWarning()", errorMessage];
    NSString *clearWarningJSCommand = [NSString stringWithFormat:@"document.getElementById('alerts').innerHTML=\"\""];
    NSString *clearPasswordJSCommand = [NSString stringWithFormat:@"document.getElementById('id_password').value=''"];
    [_webView evaluateJavaScript:clearWarningJSCommand completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    [_webView evaluateJavaScript:clearPasswordJSCommand completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}
- (void)displayEmptyUserNameWarning {
    NSString *jsString = @"UsernameWarning()";
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}
- (void)displayEmptyPasswordWarning {
    NSString *jsString = @"PasswordWarning()";
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}
- (void)closeLoginPage {
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.closeLoginPageHandler) {
                self.closeLoginPageHandler();
            }
        });
    }];
}
#pragma mark -
#pragma mark - Public Method
#pragma mark -
#pragma mark - Setter Getter Methods
#pragma mark -
#pragma mark - Notification Method
#pragma mark -
#pragma mark - External Delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.scheme isEqualToString:@"ios"]) {
        if ([navigationAction.request.URL.absoluteString isEqualToString:@"ios://notUser"]) {
            [self cancelAuthorization];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            NSString *queryString = navigationAction.request.URL.query;
            queryString = [queryString stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
            NSArray *queryArray = [self queryArrayFromQueryStrings:queryString];
            if ([queryArray count] == 2) {
                NSDictionary *firstQuery = [queryArray objectAtIndex:0];
                NSDictionary *secondQuery = [queryArray objectAtIndex:1];
                if ([[firstQuery objectForKey:@"name"] isEqualToString:@"username"]
                    && [[secondQuery objectForKey:@"name"] isEqualToString:@"password"]) {
                    NSString *userName = [firstQuery objectForKey:@"value"];
                    NSString *password = [secondQuery objectForKey:@"value"];
                    if (!userName
                        || [userName isEqualToString:@""]) {
                        [self displayEmptyUserNameWarning];
                        decisionHandler(WKNavigationActionPolicyCancel);
                    } else if (!password
                        || [password isEqualToString:@""]) {
                        [self displayEmptyPasswordWarning];
                        decisionHandler(WKNavigationActionPolicyCancel);
                    } else {
                        [self loginInstagram:userName password:password];
                        [self showAuthenticationPage];
                    }
                }
            } else if ([queryArray count] == 1) {
                NSDictionary *queryDictionary = [queryArray objectAtIndex:0];
                NSString *queryName = [queryDictionary objectForKey:@"name"];
                NSString *queryValue = [queryDictionary objectForKey:@"value"];
                [self handleQuery:queryName value:queryValue];
                decisionHandler(WKNavigationActionPolicyCancel);
            } else {
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *pagePath = DEF_Name(@"detail.html");
    [self configureWebView:![webView.URL.path isEqualToString:pagePath]];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self dealWithMessage:message];
}

- (BOOL)dealWithMessage:(WKScriptMessage *)message {
    BOOL canDeal = NO;
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)message.body;
        GPCPWebMessage *insMessage = [[GPCPWebMessage alloc] init];
        insMessage.methodName = dic[METHODNAMEKEY];
        insMessage.params = dic[PARAMSKEY];
        insMessage.callbackMethod = dic[CALLBACKMETHODKEY];
        if ([message.name isEqualToString:@"InsLoginHandler"]) {
            if ([insMessage.methodName isEqualToString:@"invokeForgetPasswordFunction"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://instagram.com/accounts/password/reset/"]];
                });
                canDeal = YES;
            } else if ([insMessage.methodName isEqualToString:@"invokeLoginWithFBFunction"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showLoginFbPage];
                });
                canDeal = YES;
            } else if ([insMessage.methodName isEqualToString:@"invokeLoginFunction"]) {
                
                self.userName = insMessage.params[@"name"];
                [self loginInstagram:insMessage.params[@"name"] password:insMessage.params[@"password"]];

                canDeal = YES;
            }
        }
    }
    return canDeal;
}

- (void)configureWebView:(BOOL)isLoginPage {
    if (isLoginPage) {
        [self configureLoginPage];
    } else {
        [self configureDetailPage];
    }
}
- (void)configureLoginPage {
    NSString *userName = NSLocalizedString(@"Username", @"Username");
    NSString *password = NSLocalizedString(@"Password", @"Password");
    NSString *forgotPassword = NSLocalizedString(@"Forgot your password", @"Forgot your password");
    NSString *login = NSLocalizedString(@"Log in", @"Log in");
    NSString *loginFB = NSLocalizedString(@"Log in With Facebook", @"Log in With Facebook");
    NSString *jsString = [NSString stringWithFormat:@"setPlaceholderUsername('%@'); setPlaceholderPassword('%@'); setPlaceholderForgotPassword('%@'); setPlaceholderLogin('%@'); setLoginByFacebook('%@')", userName, password, forgotPassword, login, loginFB];
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];

}
- (void)configureDetailPage {
    if ([IGLoginManager sharedInstance].appstore_appId.length == 0) {
        if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"appstore_appId"] length] > 0) {
            [IGLoginManager sharedInstance].appstore_appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"appstore_appId"];
        } else {
            [IGLoginManager sharedInstance].appstore_appId = @"";
        }
    }
    NSString *appLink = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", [IGLoginManager sharedInstance].appstore_appId];
    NSString *appName = [IGLoginManager sharedInstance].appstore_appName.length > 0 ? [IGLoginManager sharedInstance].appstore_appName : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *jsString = [NSString stringWithFormat:@"fillInfo('%@', '%@', '%@')", self.userName, appName, appLink];
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}
#pragma mark -
#pragma mark - IGLInsJSObject
- (void)jsObject:(IGLInsJSObject *)jsObject loginWitUserName:(NSString *)name pwd:(NSString *)password {
    self.userName = name;
    [self loginInstagram:name password:password];
}
- (void)jsObjectForgetPwd:(IGLInsJSObject *)jsObject {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://instagram.com/accounts/password/reset/"]];
    });
}
- (void)jsObjectLoginWithFB:(IGLInsJSObject *)jsObject {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoginFbPage];
    });
}

#pragma mark - LOginhelper delegate
- (void)fbLoginHelperBeginLogin:(IGLInsFBLoginHelper *)helper {
    if (self.beginLoginHandler) {
        self.beginLoginHandler(@"");
    }
}
- (void)fbLoginHelperLoginFinish:(IGLInsFBLoginHelper *)helper success:(BOOL)success checkPoint:(BOOL)checkPoint errorMessage:(NSString *)errorMessage loginUserDic:(NSDictionary *)loginUserDic cookie:(NSString *)cookie {

    if (self.loginComplete) {
        self.loginComplete(success, checkPoint, errorMessage, loginUserDic, cookie);
    }
    if (!success) {
        if (checkPoint) {
            [self checkChallenge:errorMessage];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            if([errorMessage isEqualToString:@"checkpoint_required"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"Instagram want to confirm with your about your account privacy, so you need to login the actual instagram app, and then back to login again", nil) duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:errorMessage duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
                });
            }
        }
    }

}
- (void)fbLoginHelperBeginFetchUserInfo:(IGLInsFBLoginHelper *)helper {
    if (self.beginGetUserInfoHandler) {
        self.beginGetUserInfoHandler();
    }
}
- (void)fbLoginHelperFetchUserInfoFinish:(IGLInsFBLoginHelper *)helper success:(BOOL)success errorMessage:(NSString *)errorMessage userDetailsDic:(NSDictionary *)userDetailsDic {
    if (self.getUserInfoComplete) {
        self.getUserInfoComplete(success, errorMessage, userDetailsDic);
    }
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self closeLoginPage];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorMessage duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
        });
    }
}


@end
