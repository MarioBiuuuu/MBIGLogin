//
/*******************************************************************************
    Copyright © 2019 Adrian. All rights reserved.

    File name:     IGInsLoginTopView.h
    Author:        Adrian

    Project name:  GPInstagramLogin

    Description:
    

    History:
            2019/11/20: File created.

********************************************************************************/
    

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IGInsLoginTopView : UIView
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (nonatomic, copy) void (^cloaseAction)(void);
- (void)setNeedShowClose:(BOOL)needShow;
@end

NS_ASSUME_NONNULL_END
