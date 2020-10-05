/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageDownloaderRequestModifier.h"

@interface _ChannelIO_SDWebImageDownloaderRequestModifier ()

@property (nonatomic, copy, nonnull) _ChannelIO_SDWebImageDownloaderRequestModifierBlock block;

@end

@implementation _ChannelIO_SDWebImageDownloaderRequestModifier

- (instancetype)initWithBlock:(_ChannelIO_SDWebImageDownloaderRequestModifierBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)requestModifierWithBlock:(_ChannelIO_SDWebImageDownloaderRequestModifierBlock)block {
    _ChannelIO_SDWebImageDownloaderRequestModifier *requestModifier = [[_ChannelIO_SDWebImageDownloaderRequestModifier alloc] initWithBlock:block];
    return requestModifier;
}

- (NSURLRequest *)modifiedRequestWithRequest:(NSURLRequest *)request {
    if (!self.block) {
        return nil;
    }
    return self.block(request);
}

@end

@implementation _ChannelIO_SDWebImageDownloaderRequestModifier (Conveniences)

- (instancetype)initWithMethod:(NSString *)method {
    return [self initWithMethod:method headers:nil body:nil];
}

- (instancetype)initWithHeaders:(NSDictionary<NSString *,NSString *> *)headers {
    return [self initWithMethod:nil headers:headers body:nil];
}

- (instancetype)initWithBody:(NSData *)body {
    return [self initWithMethod:nil headers:nil body:body];
}

- (instancetype)initWithMethod:(NSString *)method headers:(NSDictionary<NSString *,NSString *> *)headers body:(NSData *)body {
    method = method ? [method copy] : @"GET";
    headers = [headers copy];
    body = [body copy];
    return [self initWithBlock:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull request) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        mutableRequest.HTTPMethod = method;
        mutableRequest.HTTPBody = body;
        for (NSString *header in headers) {
            NSString *value = headers[header];
            [mutableRequest setValue:value forHTTPHeaderField:header];
        }
        return [mutableRequest copy];
    }];
}

@end
