#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface NormalHelper : NSObject
+ (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key;
+ (NSString *)stringWithFormEncodedComponents:(NSDictionary *)originalDict;
+ (NSString*)stringByEscapingForURLQuery:(NSString *)originalStr;
+ (NSString*)stringByUnescapingFromURLQuery:(NSString *)originalStr;
@end
NS_ASSUME_NONNULL_END
