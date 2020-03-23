#import <UIKit/UIKit.h>
#import "ZZRTextView.h"
NS_ASSUME_NONNULL_BEGIN
@interface IGLInsTwoFactorLoginView : UIView
@property (nonatomic, strong) ZZRTextView *tv;
@property (weak, nonatomic) IBOutlet UIView *codeView;
@property (weak, nonatomic) IBOutlet UILabel *tipLab;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UILabel *bottomLab;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (nonatomic, copy) void (^okActionHandler)(NSString *code);
@property (nonatomic, copy) void (^closeClick)(void);
@end
NS_ASSUME_NONNULL_END
