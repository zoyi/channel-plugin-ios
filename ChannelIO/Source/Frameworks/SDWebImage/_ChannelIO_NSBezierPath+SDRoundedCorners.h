/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageCompat.h"

#if SD_MAC

#import "_ChannelIO_UIImage+Transform.h"

@interface NSBezierPath (_ChannelIO_SDRoundedCorners)

/**
 Convenience way to create a bezier path with the specify rounding corners on macOS. Same as the one on `UIBezierPath`.
 */
+ (nonnull instancetype)_ChannelIO_sd_bezierPathWithRoundedRect:(NSRect)rect byRoundingCorners:(SDRectCorner)corners cornerRadius:(CGFloat)cornerRadius;

@end

#endif
