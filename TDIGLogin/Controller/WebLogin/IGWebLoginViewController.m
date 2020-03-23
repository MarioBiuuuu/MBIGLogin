

#import "IGWebLoginViewController.h"
#import "IGLoginManager.h"
#import "IGLInsCommonHeader.h"
#import "IGLInsRequest.h"
#import "IGInsLoginTopView.h"

#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Toast/Toast.h>

@interface IGWebLoginViewController ()<WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *loginUserName;
@property (nonatomic, copy) NSString *loginPassword;

@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) IGInsLoginTopView *topView;

@property (nonatomic, strong) UIView *loginLoadingView;
@property (nonatomic, strong) UILabel *indicatorLoadingLabel;

@property (nonatomic, strong) NSDictionary *loginCookieDict;
@property (nonatomic, assign) BOOL beginRequestUserInfo;
@property (nonatomic, assign) BOOL isClose;
@end

@implementation IGWebLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLoginBgView];
    [self initialUI];
    [self deleteCookie:^{
        NSURL *url = [NSURL URLWithString:@"https://www.instagram.com/accounts/login/"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isClose = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    [self resetUI];
    NSString *appName = [IGLoginManager sharedInstance].appstore_appName.length > 0 ? [IGLoginManager sharedInstance].appstore_appName : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *tip = [NSString stringWithFormat:@"%@ never sees or stores your Instagram password.", appName];
    self.tipLab.text = tip;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

}

#pragma mark -
#pragma mark - Intial Methods
- (IGInsLoginTopView *)topView {
    if (!_topView) {
        _topView = [[NSBundle bundleWithPath: DEF_BundlePath] loadNibNamed:@"IGInsLoginTopView" owner:nil options:nil].firstObject;
        _topView.frame = CGRectMake(0, 0, DEF_SCREEN_WIDTH, k_Height_NavBar);
    }
    return _topView;
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
- (void)initLoginBgView {
    if (_loginLoadingView && _loginLoadingView.superview) {
        [_loginLoadingView removeFromSuperview];
    }
    _loginLoadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    _loginLoadingView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_loginLoadingView];
    [_loginLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(k_Height_StatusBar + 44);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(-(70 + DEF_SafeAreaBottom));
    }];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.color = [UIColor grayColor];
    [_loginLoadingView addSubview:indicatorView];
    [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.width.equalTo(@30);
        make.centerX.equalTo(_loginLoadingView).offset(0);
        make.centerY.equalTo(_loginLoadingView).offset(-20);
    }];
    [indicatorView startAnimating];
    
    _indicatorLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    _indicatorLoadingLabel.font = [UIFont systemFontOfSize:14];
    _indicatorLoadingLabel.center = CGPointMake(self.view.bounds.size.width / 2 + 24, self.view.bounds.size.width / 2);
    
    _indicatorLoadingLabel.textAlignment = NSTextAlignmentCenter;
    _indicatorLoadingLabel.text = @"Loading...";
    _indicatorLoadingLabel.textColor = [UIColor darkTextColor];
    [_loginLoadingView addSubview:_indicatorLoadingLabel];
    
    [_indicatorLoadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@34);
        make.centerX.equalTo(_loginLoadingView).offset(0);
        make.centerY.equalTo(_loginLoadingView).offset(20);
    }];
    
    [self showLoginViewLoadingViewStatus:YES];
}

- (void)showLoginViewLoadingViewStatus:(BOOL)isShow {
    if (isShow) {
        NSLog(@"*-*-* showLoginViewLoadingViewStatus YES");
    } else {
        NSLog(@"*-*-* showLoginViewLoadingViewStatus NO");
    }

    _loginLoadingView.hidden = !isShow;

}

- (void)resetUI {
    
    [self.view bringSubviewToFront:_loginLoadingView];
 
}

/** 视图初始化 */
- (void)initialUI {
    __weak typeof(self) weakSelf = self;
    [self.topView setCloaseAction:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
       [strongSelf closeLoginPage];
    }];
    [self.topView setNeedShowClose:self.showCloseBtn];

    [self.view addSubview:self.webView];
    
    [self.view addSubview:self.tipView];
    [self.tipView addSubview:self.tipLab];
    [self.view addSubview:self.topView];

    self.view.backgroundColor = [UIColor colorWithRed:250.0 / 255.0 green:250.0 / 255.0 blue:250.0 / 255.0 alpha:1];
}

- (void)initialSubViews {
    
    
}

#pragma mark -
#pragma mark - Target Methods
- (void)closeBtnClick:(UIButton *)closeBtn {
    [self closeLoginPage];
    self.isClose = YES;
}

- (void)closeAction:(id)sender {
    self.isClose = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    WKWebsiteDataStore *store = [WKWebsiteDataStore defaultDataStore];
    if (@available(iOS 11.0, *)) {
        [store.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
            NSLog(@"*-*-* cookieDict = %@", cookies);

        }];
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark -
#pragma mark - Private Method
- (BOOL)firstAuthenticationUser:(NSString *)userId {
    NSString *authenKey = [NSString stringWithFormat:@"hasAuthenticationInThisDevice_%@", userId];
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:authenKey]){
        return YES;
    }else{
        return NO;
    }
}
- (void)showAuthenticationPage {
    NSString *pagePath = DEF_Name(@"detail.html");
//    NSString *pagePath = [[NSBundle bundleWithPath: DEF_BundlePath] pathForResource:@"detail" ofType:@"html"];
    NSURL *authUrl = [NSURL fileURLWithPath:pagePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:authUrl];
    [self.webView loadRequest:request];
}

- (void)handleQuery:(NSString *)queryName value:(NSString *)queryValue {
    if ([queryName isEqualToString:@"allow"]) {
        if ([queryValue isEqualToString:@"Authorize"]) {
            [self finishAuthorization];
        } else if ([queryValue isEqualToString:@"Cancel"]) {
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
    
    [self deleteCookie:^{
        self.loginCookieDict = nil;
        NSURL *url = [NSURL URLWithString:@"https://www.instagram.com/accounts/login/"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }];
    
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
  
- (void)closeLoginPage {
    
    NSLog(@"*-*-* closeLoginPage");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoginViewLoadingViewStatus:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.closeLoginPageHandler) {
                    self.closeLoginPageHandler();
                }
            });
        }];
    });
    
}



#pragma mark -
#pragma mark - Public Method

#pragma mark -
#pragma mark - Setter Getter Methods
- (void)setShowCloseBtn:(BOOL)showCloseBtn {
    _showCloseBtn = showCloseBtn;
    if (showCloseBtn) {
        self.closeBtn.hidden = NO;
    } else {
        self.closeBtn.hidden = YES;
    }
}


#pragma mark -
#pragma mark - 原生Web登陆方式

- (void)deleteCookie:(void(^)(void))completion {
    [[WKWebsiteDataStore defaultDataStore] fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] completionHandler:^(NSArray<WKWebsiteDataRecord *> * _Nonnull records) {
        for (WKWebsiteDataRecord *record in records) {
            NSLog(@"record = %@",record.displayName);
            if ([record.displayName containsString:@"instagram"]) {
                [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
                    
                }];
            }
            if ([record.displayName containsString:@"facebook"]) {
                [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
                    
                }];
            }
            
        }
        completion();
    }];
}

- (void)parseNativeCookieCompletion:(void(^)(BOOL isSuccess))compeltion {
    NSMutableDictionary *cookieDict = @{}.mutableCopy;
    WKWebsiteDataStore *store = [WKWebsiteDataStore defaultDataStore];
    if (@available(iOS 11.0, *)) {
        [store.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
            
            for (NSHTTPCookie *cookie in cookies) {
                [cookieDict setValue:cookie.value forKey:cookie.name];
            }
            self.loginCookieDict = cookieDict;
            NSString *userId = cookieDict[@"ds_user_id"];
            if (userId) {
                NSLog(@"*-*-* cookieDict = %@",userId);
                compeltion(YES);
            } else {
                compeltion(NO);
                NSLog(@"*-*-* cookieDict = 没有");
            }
            
            
        }];
    } else {
        // Fallback on earlier versions
    }
}

//TODO:拿到请求cookie、开始请求用户信息
- (void)requestUserInfoWithCookies:(NSDictionary *)cookieDict {
    NSLog(@"*-*-* requestUserInfoWithCookies");
    self.beginRequestUserInfo = YES;
    
    if (self.loginComplete) {
        NSLog(@"*-*-* self.loginComplete");
        NSMutableDictionary *cookieDict_M = @{}.mutableCopy;
        for (NSString *key in cookieDict.allKeys) {
            id value = cookieDict[key];
            if ([value isKindOfClass:[NSString class]]) {
                
                [cookieDict_M setValue:value forKey:key];
            } else {
//                NSString *valueString = [value stringValue];
//                [cookieDict_M setValue:valueString forKey:key];
            }
            
            
        }
        self.loginComplete(YES, cookieDict_M);
    }

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *userId = [cookieDict objectForKey:@"ds_user_id"];
    
    if (self.beginGetUserInfoHandler) {
        self.beginGetUserInfoHandler();
    }
    __weak typeof(self) weakSelf = self;
    [[IGLInsRequest sharedInstance] getIGUserDetailWithUserID:userId completion:^(BOOL success, NSString * _Nonnull errorMessage, NSDictionary * _Nonnull userDetailsDic) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        });
        NSLog(@"*-*-* strongSelf.getUserInfoComplete %d", success);
        NSLog(@"*-*-* strongSelf.getUserInfoComplete");
        if (strongSelf.getUserInfoComplete) {
            NSLog(@"*-*-* strongSelf.getUserInfoComplete ---");
            strongSelf.getUserInfoComplete(success, errorMessage, userDetailsDic);
        }
        if (success) {
            NSLog(@"*-*-* getIGUserDetailWithUserID success");
            
            [strongSelf closeLoginPage];
           
        } else {
            [strongSelf closeLoginPage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.view makeToast:errorMessage duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(DEF_SCREEN_WIDTH * 0.5, DEF_SCREENH_HEIGHT - DEF_SafeAreaBottom - k_Height_NavBar - 50)]];
            });
        }
    }];
    
     
    
}


#pragma mark -
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    __weak typeof(self) weakSelf = self;
    NSLog(@"*-*-* didStartProvisionalNavigation URL : %@", webView.URL.absoluteString);
    [self parseNativeCookieCompletion:^(BOOL isSuccess) {
        if (isSuccess) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!self.beginRequestUserInfo) {
                [strongSelf requestUserInfoWithCookies:strongSelf.loginCookieDict];
            }
        }
    }];
     
}
 
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"*-*-* decidePolicy navigationAction.request.URL = %@",navigationAction.request.URL.absoluteString);
    
    if ([navigationAction.request.URL.absoluteString containsString:@"https://www.instagram.com/accounts/onetap/?next="]) {
        //TODO: 点击登录按钮事件记录
        NSLog(@"*-*-* TODO: 点击登录按钮事件记录");

    }
    
    NSLog(@"*-*-* all headers : %@", navigationAction.request.allHTTPHeaderFields);
    if ([navigationAction.request.URL.scheme isEqualToString:@"ios"]) {
        if ([navigationAction.request.URL.absoluteString isEqualToString:@"ios://notUser"]) {
            
            decisionHandler(WKNavigationActionPolicyCancel);
            [self cancelAuthorization];

        } else {
            
            NSString *queryString = navigationAction.request.URL.query;
            queryString = [queryString stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
            NSArray *queryArray = [self queryArrayFromQueryStrings:queryString];
            if ([queryArray count] == 1) {
                NSDictionary *queryDictionary = [queryArray objectAtIndex:0];
                NSString *queryName = [queryDictionary objectForKey:@"name"];
                NSString *queryValue = [queryDictionary objectForKey:@"value"];
                [self handleQuery:queryName value:queryValue];
                if ([queryValue isEqualToString:@"Cancel"]) {
                    decisionHandler(WKNavigationActionPolicyAllow);
                } else {
                    decisionHandler(WKNavigationActionPolicyCancel);
                }
            } else {
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        }
    } else {

        BOOL hasUserId = NO;

        if (self.loginCookieDict) {
            NSLog(@"*-*-* self.loginCookieDict");
            for (NSString *key in self.loginCookieDict.allKeys) {
                if ([key containsString:@"ds_user_id"]) {
                    hasUserId = YES;
                }
            }
        }
        
        
        if ([navigationAction.request.URL.absoluteString containsString:@"detail.html"]) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            
            if (hasUserId) {
                if (!self.beginRequestUserInfo) {
                    [self requestUserInfoWithCookies:self.loginCookieDict];
                }
                decisionHandler(WKNavigationActionPolicyCancel);
            } else {
                NSLog(@"*-*-* begin get cookie");
                NSLog(@"*-*-* navigationAction.request url %@",navigationAction.request.URL.absoluteString);
                // TODO:
                
                if ([navigationAction.request.URL.absoluteString isEqualToString:@"https://www.instagram.com/"]) {
                    [self showLoginViewLoadingViewStatus:YES];
                    NSLog(@"*-*-* testWithLoop:YES");
                    [self testWithLoop:YES completion:^{
                        NSLog(@"*-*-* cookie finished");
                    }];
                } else if ([navigationAction.request.URL.absoluteString isEqualToString:@"https://www.instagram.com/accounts/login/"])  {
                    NSLog(@"*-*-* testWithLoop https://www.instagram.com/accounts/login/ :NO");
                    [self testWithLoop:NO completion:^{
                        NSLog(@"*-*-* cookie finished");
                    }];
                } else if ([navigationAction.request.URL.absoluteString containsString:@"https://m.facebook.com/login"]) {
                    NSLog(@"*-*-* testWithLoop https://m.facebook.com/login :NO");
                    [self testWithLoop:NO completion:^{
                        NSLog(@"*-*-* cookie finished");
                    }];
                } else {
                    NSLog(@"*-*-* testWithLoop other :Yes");
                    [self testWithLoop:YES completion:^{
                        NSLog(@"*-*-* cookie finished");
                    }];
                }
                decisionHandler(WKNavigationActionPolicyAllow);
            }

        }
         
    }
}

- (void)testWithLoop:(BOOL)loop completion:(void(^)(void))completionm {
    __weak typeof(self) weakSelf = self;
    NSLog(@"*-*-* get cookie testWithLoop --");

    if (self.beginRequestUserInfo || self.isClose) {
        NSLog(@"*-*-* if (self.beginRequestUserInfo) {");
        return;
    }
    
    if (loop) {
        NSLog(@"*-*-* testWithLoop:(BOOL)loop = YES");
    } else {
        NSLog(@"*-*-* testWithLoop:(BOOL)loop = NO");
    }
    
    [self parseNativeCookieCompletion:^(BOOL isSuccess) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (isSuccess) {
             NSLog(@"*-*-* if (strongSelf.loginCookieDict) {");
             if (!self.beginRequestUserInfo) {
                 NSLog(@"*-*-* if (!self.beginRequestUserInfo) {");
                 [strongSelf requestUserInfoWithCookies:strongSelf.loginCookieDict];
             }
             completionm();
        } else {
            NSLog(@"*-*-* if (!self.beginRequestUserInfo) { } else { ");
            if (loop){
                NSLog(@"*-*-* if (loop){");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf testWithLoop:loop completion:completionm];
                });
                
            }
        }
    }];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
}
//
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *pagePath = DEF_Name(@"detail.html");
    NSLog(@"*-*-* didFinishNavigation URL : %@", webView.URL.absoluteString);
    if ([webView.URL.path isEqualToString:pagePath]) {
        if ([IGLoginManager sharedInstance].appstore_appId.length == 0) {
            if ([[[[NSBundle bundleWithPath: DEF_BundlePath] infoDictionary] objectForKey:@"appstore_appId"] length] > 0) {
                [IGLoginManager sharedInstance].appstore_appId = [[[NSBundle bundleWithPath: DEF_BundlePath] infoDictionary] objectForKey:@"appstore_appId"];
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
    
    if ([webView.URL.absoluteString isEqualToString:@"https://www.instagram.com/accounts/login/"]) {
        [self showLoginViewLoadingViewStatus:NO];
    }
 
}
@end
