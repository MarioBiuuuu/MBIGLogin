#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface IGLInsLoginChallengeView : UIView
@property (weak, nonatomic) IBOutlet UIButton *emailBtn;
@property (weak, nonatomic) IBOutlet UIButton *mobileBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mobileHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mobileTop;
@property (nonatomic, copy) void (^emailClick)(void);
@property (nonatomic, copy) void (^mobileClick)(void);
@property (nonatomic, copy) void (^sendActionClick)(NSString *type);
@property (nonatomic, copy) void (^closeClick)(void);
@end
NS_ASSUME_NONNULL_END
