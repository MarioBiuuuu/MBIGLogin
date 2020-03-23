//
/*******************************************************************************
    Copyright © 2019 Adrian. All rights reserved.

    File name:     IGInsLoginTopView.m
    Author:        Adrian

    Project name:  GPInstagramLogin

    Description:
    

    History:
            2019/11/20: File created.

********************************************************************************/
    

#import "IGInsLoginTopView.h"

@implementation IGInsLoginTopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)closeAction:(id)sender {
    if (self.cloaseAction) {
        self.cloaseAction();
    }
}
- (void)setNeedShowClose:(BOOL)needShow {
    self.closeBtn.hidden = !needShow;
}
@end
