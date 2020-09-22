/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIImage+ForceDecode.h"
#import "_ChannelIO_SDImageCoderHelper.h"
#import "objc/runtime.h"

@implementation UIImage (_ChannelIO_ForceDecode)

- (BOOL)_ChannelIO_sd_isDecoded {
    NSNumber *value = objc_getAssociatedObject(self, @selector(_ChannelIO_sd_isDecoded));
    return value.boolValue;
}

- (void)set_ChannelIO_sd_isDecoded:(BOOL)sd_isDecoded {
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_isDecoded), @(sd_isDecoded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (nullable UIImage *)_ChannelIO_sd_decodedImageWithImage:(nullable UIImage *)image {
    if (!image) {
        return nil;
    }
    return [_ChannelIO_SDImageCoderHelper decodedImageWithImage:image];
}

+ (nullable UIImage *)_ChannelIO_sd_decodedAndScaledDownImageWithImage:(nullable UIImage *)image {
    return [self _ChannelIO_sd_decodedAndScaledDownImageWithImage:image limitBytes:0];
}

+ (nullable UIImage *)_ChannelIO_sd_decodedAndScaledDownImageWithImage:(nullable UIImage *)image limitBytes:(NSUInteger)bytes {
    if (!image) {
        return nil;
    }
    return [_ChannelIO_SDImageCoderHelper decodedAndScaledDownImageWithImage:image limitBytes:bytes];
}

@end
