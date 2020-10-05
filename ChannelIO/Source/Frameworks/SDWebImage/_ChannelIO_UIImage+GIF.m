/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Laurin Brandner
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIImage+GIF.h"
#import "_ChannelIO_SDImageGIFCoder.h"

@implementation UIImage (_ChannelIO_GIF)

+ (nullable UIImage *)_ChannelIO_sd_imageWithGIFData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    return [[_ChannelIO_SDImageGIFCoder sharedCoder] decodedImageWithData:data options:0];
}

@end
