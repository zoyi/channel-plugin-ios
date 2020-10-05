/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIImage+WebP.h"
#import "_ChannelIO_SDImageWebPCoder.h"

@implementation UIImage (_ChannelIO_WebP)

+ (nullable UIImage *)_ChannelIO_sd_imageWithWebPData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    return [[_ChannelIO_SDImageWebPCoder sharedCoder] decodedImageWithData:data options:0];
}

@end
