/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
#import <Foundation/Foundation.h>
#import "_ChannelIO_SDImageIOAnimatedCoder.h"
/**
 Built in coder that supports WebP and animated WebP
 */
@interface _ChannelIO_SDImageWebPCoder : NSObject <_ChannelIO_SDProgressiveImageCoder, _ChannelIO_SDAnimatedImageCoder>

@property (nonatomic, class, readonly, nonnull) _ChannelIO_SDImageWebPCoder *sharedCoder;

@end
