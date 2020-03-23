#import "IGLInsJSObject.h"
typedef NS_ENUM(NSInteger, JSCallBackAction) {
    JSCallBackActionLoginWithUserName = 0,
    JSCallBackActionForgetPassword,
    JSCallBackActionLoginWithFacebook,
};
@implementation IGLInsJSObject
- (instancetype)initWithCallBackDelegate:(id <IGLInsJSObjectDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}
- (void)loginPagePrivateAction:(JSCallBackAction)actionType arguments:(NSDictionary *)arguments {
    if (!self.delegate) {
        return;
    }
    switch (actionType) {
        case JSCallBackActionLoginWithUserName:{
            if ([self.delegate respondsToSelector:@selector(jsObject:loginWitUserName:pwd:)]) {
                [self.delegate jsObject:self loginWitUserName:arguments[@"name"] pwd:arguments[@"password"]];
            }
        }
            break;
        case JSCallBackActionForgetPassword:{
            if ([self.delegate respondsToSelector:@selector(jsObjectForgetPwd:)]) {
                [self.delegate jsObjectForgetPwd:self];
            }
        }
            break;
        case JSCallBackActionLoginWithFacebook:{
            if ([self.delegate respondsToSelector:@selector(jsObjectLoginWithFB:)]) {
                [self.delegate jsObjectLoginWithFB:self];
            }
        }
            break;
        default:
            break;
    }
}
- (void)callLoginWithDict:(NSDictionary *)params {
    [self loginPagePrivateAction:JSCallBackActionLoginWithUserName arguments:params];
}
- (void)callForgetPassword {
    [self loginPagePrivateAction:JSCallBackActionForgetPassword arguments:nil];
}
- (void)callLoginWithFB {
    [self loginPagePrivateAction:JSCallBackActionLoginWithFacebook arguments:nil];
}
@end
