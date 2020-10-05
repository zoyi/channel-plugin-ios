/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIImage+MultiFormat.h"
#import "_ChannelIO_SDImageCodersManager.h"

@implementation UIImage (_ChannelIO_MultiFormat)

+ (nullable UIImage *)_ChannelIO_sd_imageWithData:(nullable NSData *)data {
    return [self _ChannelIO_sd_imageWithData:data scale:1];
}

+ (nullable UIImage *)_ChannelIO_sd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale {
    return [self _ChannelIO_sd_imageWithData:data scale:scale firstFrameOnly:NO];
}

+ (nullable UIImage *)_ChannelIO_sd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale firstFrameOnly:(BOOL)firstFrameOnly {
    if (!data) {
        return nil;
    }
    _ChannelIO_SDImageCoderOptions *options = @{_ChannelIO_SDImageCoderDecodeScaleFactor : @(MAX(scale, 1)), _ChannelIO_SDImageCoderDecodeFirstFrameOnly : @(firstFrameOnly)};
    return [[_ChannelIO_SDImageCodersManager sharedManager] decodedImageWithData:data options:options];
}

- (nullable NSData *)_ChannelIO_sd_imageData {
    return [self _ChannelIO_sd_imageDataAsFormat:_ChannelIO_SDImageFormatUndefined];
}

- (nullable NSData *)_ChannelIO_sd_imageDataAsFormat:(_ChannelIO_SDImageFormat)imageFormat {
    return [self _ChannelIO_sd_imageDataAsFormat:imageFormat compressionQuality:1];
}

- (nullable NSData *)_ChannelIO_sd_imageDataAsFormat:(_ChannelIO_SDImageFormat)imageFormat compressionQuality:(double)compressionQuality {
    return [self _ChannelIO_sd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:NO];
}

- (nullable NSData *)_ChannelIO_sd_imageDataAsFormat:(_ChannelIO_SDImageFormat)imageFormat compressionQuality:(double)compressionQuality firstFrameOnly:(BOOL)firstFrameOnly {
    _ChannelIO_SDImageCoderOptions *options = @{_ChannelIO_SDImageCoderEncodeCompressionQuality : @(compressionQuality), _ChannelIO_SDImageCoderEncodeFirstFrameOnly : @(firstFrameOnly)};
    return [[_ChannelIO_SDImageCodersManager sharedManager] encodedDataWithImage:self format:imageFormat options:options];
}

@end
