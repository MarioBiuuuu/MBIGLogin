#import "IGLInsFBLoginViewController.h"
#import "IGLInsCommonHeader.h"
#import "IGLInsFBLoginHelper.h"
#import "IGLInsNotificationSet.h"
#import "IGLInsCustomURLProtocol.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>
@interface IGLInsFBLoginViewController () <WKNavigationDelegate, WKUIDelegate, IGLInsFBLoginHelperDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end
@implementation IGLInsFBLoginViewController
#pragma mark -
#pragma mark - LifeCyle
- (void)dealloc {
	NSLog(@" %@ - 释放了 ", self.class);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialNotification];
    [self initialUI];
	[self initialData];
    [self loadFBLoginWeb];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    [NSURLProtocol registerClass:[IGLInsCustomURLProtocol class]];
    [self clearWebCache];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [NSURLProtocol unregisterClass:[IGLInsCustomURLProtocol class]];
	[super viewDidDisappear:animated];
}
#pragma mark -
#pragma mark - Intial Methods
- (void)initialNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_cancelFBAuth:) name:IGLInsFBLoginCancelNotification_Login object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_FBAuthSuccess:) name:IGLInsFBLoginSuccessNotification_Login object:nil];
}
- (void)initialUI {
	[self initialNavigation];
	[self initialSubViews];
    [self updateConstraints];
}
- (void)initialNavigation {
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(nav_cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}
- (void)initialSubViews {
    [self.view addSubview:self.webView];
}
- (void)updateConstraints {
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(k_Height_NavBar);
        make.bottom.mas_equalTo(-DEF_SafeAreaBottom);
    }];
}
- (void)initialData {
}
#pragma mark -
#pragma mark - Lazy Load
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.navigationDelegate = self;
    }
    return _webView;
}
#pragma mark -
#pragma mark - Target Methods
- (void)nav_cancelAction:(UIBarButtonItem *)item {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark - Private Method
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
- (void)loadFBLoginWeb {
    NSString *fbKey = [IGLInsFBLoginHelper sharedInstance].fbKey;
    NSString *deviceUDID = [[NSUUID UUID] UUIDString];
    NSString *urlStr = [NSString stringWithFormat:@"https://m.facebook.com/login.php?skip_api_login=1&api_key=%@&signed_next=1&next=https%%3A%%2F%%2Fm.facebook.com%%2Fv2.10%%2Fdialog%%2Foauth%%3Fredirect_uri%%3Dfb%@%%253A%%252F%%252Fauthorize%%252F%%26display%%3Dtouch%%26state%%3D%%257B%%2522challenge%%2522%%253A%%2522EuHhmFqBfFMCtgrRnaJGnvkoqEMEwoRR%%2522%%252C%%25220_auth_logger_id%%2522%%253A%%2522%@%%2522%%252C%%2522com.facebook.sdk_client_state%%2522%%253A%%2522true%%2522%%252C%%25223_method%%2522%%253A%%2522sfvc_auth%%2522%%257D%%26scope%%26response_type%%3Dtoken%%252Csigned_request%%26default_audience%%3Dfriends%%26return_scopes%%3Dtrue%%26auth_type%%3Drerequest%%26client_id%%3D%@%%26ret%%3Dlogin%%26sdk%%3Dios%%26fbapp_pres%%3D1%%26sdk_version%%3DSDK_VERSION_TO_RELEASE%%26local_client_id%%26logger_id%%3D%@&cancel_url=fb%@%%3A%%2F%%2Fauthorize%%2F%%3Ferror%%3Daccess_denied%%26error_code%%3D200%%26error_description%%3DPermissions%%2Berror%%26error_reason%%3Duser_denied%%26state%%3D%%257B%%2522challenge%%2522%%253A%%2522EuHhmFqBfFMCtgrRnaJGnvkoqEMEwoRR%%2522%%252C%%25220_auth_logger_id%%2522%%253A%%2522%@%%2522%%252C%%2522com.facebook.sdk_client_state%%2522%%253A%%2522true%%2522%%252C%%25223_method%%2522%%253A%%2522sfvc_auth%%2522%%257D%%26e2e%%3D%%257B%%2522init%%2522%%253A0.513897%%257D%%23_%%3D_&display=touch&locale=zh_CN&logger_id=%@&_rdr", fbKey, fbKey, deviceUDID, fbKey, deviceUDID, fbKey, deviceUDID, deviceUDID];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}
#pragma mark -
#pragma mark - Public Method
#pragma mark -
#pragma mark - Setter Getter Methods
#pragma mark -
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
}
#pragma mark -
#pragma mark - Notification Method
- (void)noti_cancelFBAuth:(NSNotification *)noti {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)noti_FBAuthSuccess:(NSNotification *)noti {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark - External Delegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_webView evaluateJavaScript:@"document.getElementsByClassName('_kmt')[0].style.display = 'none';" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    [_webView evaluateJavaScript:@"document.getElementsByClassName('_1x84')[0].style.display = 'none';" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}

@end
