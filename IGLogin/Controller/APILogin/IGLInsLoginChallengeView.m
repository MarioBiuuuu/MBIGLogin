#import "IGLInsLoginChallengeView.h"
@implementation IGLInsLoginChallengeView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.emailBtn.selected = YES;
}
- (IBAction)emailAction:(id)sender {
    self.emailBtn.selected = YES;
    self.mobileBtn.selected = NO;
    if (self.emailClick) {
        self.emailClick();
    }
}
- (IBAction)mobileAction:(id)sender {
    self.emailBtn.selected = NO;
    self.mobileBtn.selected = YES;
    if (self.mobileClick) {
        self.mobileClick();
    }
}
- (IBAction)sendAction:(id)sender {
    if (self.sendActionClick) {
        self.sendActionClick(self.emailBtn.isSelected? @"1" : @"0");
    }
}
- (IBAction)closeAction:(id)sender {
    if (self.closeClick) {
        self.closeClick();
    }
}
@end
