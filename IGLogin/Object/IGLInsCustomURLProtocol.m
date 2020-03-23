#import "IGLInsCustomURLProtocol.h"
#import "IGLInsFBLoginHelper.h"
static NSString * const URLProtocolHandledKey =   @"URLProtocolHandledKey";
@interface IGLInsCustomURLProtocol ()<NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@end
@implementation IGLInsCustomURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *scheme = [[request URL] scheme];
    NSLog(@"request - %@", request);
    if ([scheme isEqualToString:[NSString stringWithFormat:@"fb%@", [IGLInsFBLoginHelper sharedInstance].fbKey]]) {
        [[IGLInsFBLoginHelper sharedInstance] handleFBLoginUrl:request.URL app:nil options:nil];
        [NSURLProtocol unregisterClass:[IGLInsCustomURLProtocol class]];
        return NO;
    }
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame)) {
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}
+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}
- (void)startLoading {
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    NSLog(@" test - %@", mutableReqeust);
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
}
- (void)stopLoading {
    [self.connection cancel];
}
#pragma mark - NSURLConnectionDelegate
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse *)response;
    if([httpresponse respondsToSelector:@selector(allHeaderFields)]){
        NSDictionary *di  = [httpresponse allHeaderFields];
        NSArray *keys = [di allKeys];
        for(int i=0; i<di.count;i++){
            NSString *key = [keys objectAtIndex:i];
            NSString *value=[di objectForKey:key];
            if([key rangeOfString:@"Set-Cookie"].location != NSNotFound)
            {
                NSLog(@"response_header_value -- %@",value);
            }
        }
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}
@end
