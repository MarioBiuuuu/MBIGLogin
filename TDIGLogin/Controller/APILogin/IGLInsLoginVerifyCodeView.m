#import "IGLInsLoginVerifyCodeView.h"
#import "ZZRTextView.h"
@interface IGLInsLoginVerifyCodeView () <ZZRTextViewDelegate>
@property (nonatomic, copy) NSString *codeStr;
@end
@implementation IGLInsLoginVerifyCodeView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.okBtn.enabled = NO;
    [self.okBtn setBackgroundColor:[UIColor lightGrayColor]];
    ZZRTextView *tv = [[ZZRTextView alloc] initWithFrame:CGRectMake(0, 0, 220, 40) CodeSize:CGSizeMake(30, 40) MaxCount:6];
    [tv setUpTextWithNormalTextColor:[UIColor blackColor] HighlightTextColor:[UIColor blackColor] TextFont:[UIFont systemFontOfSize:15.f] TextAlignment:NSTextAlignmentCenter KeyboardType:UIKeyboardTypeNumberPad];
    [tv setUpBorderWithNormalBorderColor:[UIColor lightGrayColor] HighlightBorderColor:[UIColor grayColor] BorderWidth:1 BorderCornerRadius:3];
    tv.delegate = self;
    self.tv = tv;
    [self.codeView addSubview:tv];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}
- (IBAction)okAction:(id)sender {
    if (self.okActionHandler) {
        self.okActionHandler(self.codeStr);
    }
}
- (void)ZZRTextViewDidChangeEdit:(NSString *)codeStr {
    self.codeStr = codeStr;
    if (codeStr.length >= 6) {
        self.okBtn.enabled = YES;
        [self.okBtn setBackgroundColor:[UIColor colorWithRed:14.0 / 255.0 green:129.0 / 255.0 blue:221.0 / 255.0 alpha:1]];
    } else {
        self.okBtn.enabled = NO;
        [self.okBtn setBackgroundColor:[UIColor lightGrayColor]];
    }
}
- (void)ZZRTextViewDidFinishedEdit:(NSString *)codeStr {
    self.codeStr = codeStr;
    if (codeStr.length >= 6) {
        self.okBtn.enabled = YES;
        [self.okBtn setBackgroundColor:[UIColor colorWithRed:14.0 / 255.0 green:129.0 / 255.0 blue:221.0 / 255.0 alpha:1]];
    } else {
        self.okBtn.enabled = NO;
        [self.okBtn setBackgroundColor:[UIColor lightGrayColor]];
    }
}
- (IBAction)resenAction:(id)sender {
    if (self.resendCodeHandler) {
        self.resendCodeHandler();
    }
}
- (IBAction)closeAction:(id)sender {
    if (self.closeClick) {
        self.closeClick();
    }
}
@end
