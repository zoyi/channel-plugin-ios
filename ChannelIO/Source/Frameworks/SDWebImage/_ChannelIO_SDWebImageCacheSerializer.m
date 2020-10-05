/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageCacheSerializer.h"

@interface _ChannelIO_SDWebImageCacheSerializer ()

@property (nonatomic, copy, nonnull) _ChannelIO_SDWebImageCacheSerializerBlock block;

@end

@implementation _ChannelIO_SDWebImageCacheSerializer

- (instancetype)initWithBlock:(_ChannelIO_SDWebImageCacheSerializerBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)cacheSerializerWithBlock:(_ChannelIO_SDWebImageCacheSerializerBlock)block {
    _ChannelIO_SDWebImageCacheSerializer *cacheSerializer = [[_ChannelIO_SDWebImageCacheSerializer alloc] initWithBlock:block];
    return cacheSerializer;
}

- (NSData *)cacheDataWithImage:(UIImage *)image originalData:(NSData *)data imageURL:(nullable NSURL *)imageURL {
    if (!self.block) {
        return nil;
    }
    return self.block(image, data, imageURL);
}

@end
