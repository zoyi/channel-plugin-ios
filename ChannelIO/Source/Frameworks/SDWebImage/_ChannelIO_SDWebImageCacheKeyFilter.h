/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "_ChannelIO_SDWebImageCompat.h"

typedef NSString * _Nullable(^_ChannelIO_SDWebImageCacheKeyFilterBlock)(NSURL * _Nonnull url);

/**
 This is the protocol for cache key filter.
 We can use a block to specify the cache key filter. But Using protocol can make this extensible, and allow Swift user to use it easily instead of using `@convention(block)` to store a block into context options.
 */
@protocol _ChannelIO_SDWebImageCacheKeyFilter <NSObject>

- (nullable NSString *)cacheKeyForURL:(nonnull NSURL *)url;

@end

/**
 A cache key filter class with block.
 */
@interface _ChannelIO_SDWebImageCacheKeyFilter : NSObject <_ChannelIO_SDWebImageCacheKeyFilter>

- (nonnull instancetype)initWithBlock:(nonnull _ChannelIO_SDWebImageCacheKeyFilterBlock)block;
+ (nonnull instancetype)cacheKeyFilterWithBlock:(nonnull _ChannelIO_SDWebImageCacheKeyFilterBlock)block;

@end
