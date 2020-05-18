#import <UIKit/UIKit.h>
typedef void(^TextDidFinished)(NSString *codeStr);
@protocol ZZRTextViewDelegate <NSObject>
@optional
- (void)ZZRTextViewDidFinishedEdit:(NSString *)codeStr;
- (void)ZZRTextViewDidChangeEdit:(NSString *)codeStr;
@end
@interface ZZRTextView : UIView<ZZRTextViewDelegate>
@property (nonatomic ,copy) TextDidFinished    textFinished;       
@property (nonatomic ,weak) id<ZZRTextViewDelegate> delegate;      
- (void)clearCode;
- (instancetype)initWithFrame:(CGRect)frame CodeSize:(CGSize)size MaxCount:(NSInteger)maxCount;
- (void)setUpBorderWithNormalBorderColor:(UIColor *)normalBorderColor
                    HighlightBorderColor:(UIColor *)highlightBorderColor
                             BorderWidth:(CGFloat)borderColor
                      BorderCornerRadius:(CGFloat)borderCornerRadius;
- (void)setUpTextWithNormalTextColor:(UIColor *)normalTextColor
                  HighlightTextColor:(UIColor *)highlightColor
                            TextFont:(UIFont *)textFont
                       TextAlignment:(NSTextAlignment)alignment
                        KeyboardType:(UIKeyboardType)keyboardType;
@end
