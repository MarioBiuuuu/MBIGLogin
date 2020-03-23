#import "NormalHelper.h"
#import <CommonCrypto/CommonHMAC.h>
@implementation NormalHelper
+ (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSString *hash;
    NSMutableString* output = [NSMutableString   stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
}
+ (NSString *)stringWithFormEncodedComponents:(NSDictionary *)originalDict {
  NSMutableArray* arguments = [NSMutableArray arrayWithCapacity:[originalDict count]];
  for (NSString* key in originalDict) {
    [arguments addObject:[NSString stringWithFormat:@"%@=%@",
                          [self stringByEscapingForURLQuery:key],
                          [self stringByEscapingForURLQuery:[[originalDict objectForKey:key] description]]]];
  }
  return [arguments componentsJoinedByString:@"&"];
}
+ (NSString*)stringByEscapingForURLQuery:(NSString *)originalStr {
  NSString *result = originalStr;
  CFStringRef originalAsCFString = (__bridge CFStringRef) originalStr;
  CFStringRef leaveAlone = CFSTR(" ");
  CFStringRef toEscape = CFSTR("\n\r?[]()$,!'*;:@&=#%+/");
  CFStringRef escapedStr;
  escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalAsCFString, leaveAlone, toEscape, kCFStringEncodingUTF8);
  if (escapedStr) {
    NSMutableString *mutable = [NSMutableString stringWithString:(__bridge NSString *)escapedStr];
    CFRelease(escapedStr);
    [mutable replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutable length])];
    result = mutable;
  }
  return result;
}
+ (NSString*)stringByUnescapingFromURLQuery:(NSString *)originalStr {
  return [[originalStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}
@end
