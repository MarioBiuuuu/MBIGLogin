#import "ZZRTextView.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ZZRTextView()<UITextViewDelegate>
@property (nonatomic ,strong) UITextView            *textView;
@property (nonatomic ,strong) UIView                *backgroundView;
@property (nonatomic ,assign) NSInteger         maxCount;           
@property (nonatomic ,strong) UIColor          *normalTextColor;          
@property (nonatomic ,strong) UIColor          *highlightTextColor;       
@property (nonatomic ,strong) UIColor          *normalBorderColor;        
@property (nonatomic ,strong) UIColor          *highlightBorderColor;     
@end
@implementation ZZRTextView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.textView = [[UITextView alloc] initWithFrame:self.bounds];
        self.textView.tintColor = [UIColor clearColor];
        self.textView.textColor = [UIColor clearColor];
        self.textView.delegate = self;
        self.textView.keyboardType = UIKeyboardTypeNumberPad;
        [self addSubview:self.textView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame CodeSize:(CGSize)size MaxCount:(NSInteger)maxCount
{
    self = [self initWithFrame:frame];
    _maxCount = maxCount;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTap)];
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    [self.backgroundView addGestureRecognizer:tapGes];
    [self addSubview:self.backgroundView];
    for(UIView *subView in [self.backgroundView subviews])
    {
        [subView removeFromSuperview];
    }
    for(NSInteger i = 0 ; i < maxCount ; i ++)
    {
        UILabel *showLabel = [UILabel new];
        showLabel.textAlignment = NSTextAlignmentCenter;
        showLabel.backgroundColor = [UIColor whiteColor];
        showLabel.textColor = [UIColor blackColor];
        showLabel.layer.borderWidth = 1;
        showLabel.layer.borderColor =[UIColor lightGrayColor].CGColor;
        showLabel.layer.cornerRadius = 5;
        showLabel.tag = 1000 + i;
        CGFloat space = (frame.size.width - size.width * maxCount)/(maxCount - 1);
        showLabel.frame = CGRectMake(i * (size.width + space) , (frame.size.height - size.height)/2.0, size.width, size.height);
        [self.backgroundView addSubview:showLabel];
    }
    return self;
}
#pragma mark -
#pragma mark - setUp
- (void)setUpBorderWithNormalBorderColor:(UIColor *)normalBorderColor
                    HighlightBorderColor:(UIColor *)highlightBorderColor
                             BorderWidth:(CGFloat)borderColor
                      BorderCornerRadius:(CGFloat)borderCornerRadius
{
    self.normalBorderColor = normalBorderColor;
    self.highlightBorderColor = highlightBorderColor;
    for(NSInteger i = 0 ; i < _maxCount ; i++)
    {
        UILabel *showLabel = (UILabel *)[self.backgroundView viewWithTag:1000+i];
        showLabel.layer.borderColor = normalBorderColor.CGColor;
        showLabel.layer.borderWidth = borderColor;
        showLabel.layer.cornerRadius =borderCornerRadius;
    }
}
- (void)setUpTextWithNormalTextColor:(UIColor *)normalTextColor
                  HighlightTextColor:(UIColor *)highlightColor
                            TextFont:(UIFont *)textFont
                       TextAlignment:(NSTextAlignment)alignment
                        KeyboardType:(UIKeyboardType)keyboardType
{
    self.textView.keyboardType = keyboardType;
    self.normalTextColor = normalTextColor;
    self.highlightBorderColor = highlightColor;
    for(NSInteger i = 0 ; i < _maxCount ; i++)
    {
        UILabel *showLabel = (UILabel *)[self.backgroundView viewWithTag:1000+i];
        showLabel.textColor = normalTextColor;
        showLabel.font = textFont;
        showLabel.textAlignment = alignment;
    }
}
#pragma mark -
#pragma mark - GestureRecognizer
- (void)backgroundViewTap
{
    [self.textView becomeFirstResponder];
    NSInteger length = self.textView.text.length;
    UILabel *selectLabel = nil;
    if(length == 0)
    {
        selectLabel = (UILabel *)[self.backgroundView viewWithTag:1000];
    }
    else
    {
        selectLabel = (UILabel *)[self.backgroundView viewWithTag:1000 + length - 1];
    }
    selectLabel.layer.borderColor = self.highlightBorderColor.CGColor;
    selectLabel.textColor = self.highlightTextColor;
}
#pragma mark -
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger length = textView.text.length;
    if(length == _maxCount)
    {
        [self.textView resignFirstResponder];
        if(self.textFinished)
        {
            self.textFinished(textView.text);
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(ZZRTextViewDidFinishedEdit:)])
        {
            [self.delegate ZZRTextViewDidFinishedEdit:textView.text];
        }
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(ZZRTextViewDidChangeEdit:)])
    {
        [self.delegate ZZRTextViewDidChangeEdit:textView.text];
    }
    for(NSInteger i = 0 ; i < _maxCount ; i++)
    {
        UILabel *showLabel = (UILabel *)[self.backgroundView viewWithTag:1000+i];
        showLabel.text = @"";
        showLabel.layer.borderColor = self.normalBorderColor.CGColor;
        showLabel.textColor = self.normalTextColor;
    }
    UILabel *selectLabel = (UILabel *)[self.backgroundView viewWithTag:1000 + length];
    selectLabel.layer.borderColor = self.highlightBorderColor.CGColor;
    selectLabel.textColor = self.highlightTextColor;
    for(NSInteger i = 0 ; i < length ; i++)
    {
        UILabel *showLabel = (UILabel *)[self.backgroundView viewWithTag:1000+i];
        NSString *subString = [textView.text substringWithRange:NSMakeRange(i, 1)];
        showLabel.text = subString;
    }
}
- (void)clearCode {
    self.textView.text = @"";
    for(NSInteger i = 0 ; i < _maxCount ; i++)
    {
        UILabel *showLabel = (UILabel *)[self.backgroundView viewWithTag:1000+i];
        showLabel.text = @"";
        showLabel.layer.borderColor = self.normalBorderColor.CGColor;
        showLabel.textColor = self.normalTextColor;
    }
    UILabel *selectLabel = (UILabel *)[self.backgroundView viewWithTag:1000];
    selectLabel.layer.borderColor = self.highlightBorderColor.CGColor;
    selectLabel.textColor = self.highlightTextColor;
}
@end
