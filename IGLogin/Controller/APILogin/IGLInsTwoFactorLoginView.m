#import "IGLInsTwoFactorLoginView.h"
@interface IGLInsTwoFactorLoginView () <ZZRTextViewDelegate>
@property (nonatomic, copy) NSString *codeStr;
@end
@implementation IGLInsTwoFactorLoginView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.okBtn.enabled = YES;
    [self.okBtn setBackgroundColor:[UIColor colorWithRed:14.0 / 255.0 green:129.0 / 255.0 blue:221.0 / 255.0 alpha:1]];
    NSAttributedString *attstr = [[NSAttributedString alloc] initWithString:@"verification code" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    self.codeTF.attributedPlaceholder = attstr;
    self.codeTF.layer.borderWidth = 1;
    self.codeTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.codeTF.layer.cornerRadius = 5;
    self.codeTF.layer.masksToBounds = YES;
    self.codeTF.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}
- (IBAction)okAction:(id)sender {
    if (self.codeTF.text.length > 0) {
        if (self.okActionHandler) {
            self.okActionHandler(self.codeTF.text);
        }
    }
}
- (IBAction)closeAction:(id)sender {
    if (self.closeClick) {
        self.closeClick();
    }
}
@end
