/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageCacheKeyFilter.h"

@interface _ChannelIO_SDWebImageCacheKeyFilter ()

@property (nonatomic, copy, nonnull) _ChannelIO_SDWebImageCacheKeyFilterBlock block;

@end

@implementation _ChannelIO_SDWebImageCacheKeyFilter

- (instancetype)initWithBlock:(_ChannelIO_SDWebImageCacheKeyFilterBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)cacheKeyFilterWithBlock:(_ChannelIO_SDWebImageCacheKeyFilterBlock)block {
    _ChannelIO_SDWebImageCacheKeyFilter *cacheKeyFilter = [[_ChannelIO_SDWebImageCacheKeyFilter alloc] initWithBlock:block];
    return cacheKeyFilter;
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!self.block) {
        return nil;
    }
    return self.block(url);
}

@end
