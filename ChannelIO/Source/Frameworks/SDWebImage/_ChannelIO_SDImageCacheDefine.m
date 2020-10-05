/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDImageCacheDefine.h"
#import "_ChannelIO_SDImageCodersManager.h"
#import "_ChannelIO_SDImageCoderHelper.h"
#import "_ChannelIO_SDAnimatedImage.h"
#import "_ChannelIO_UIImage+Metadata.h"
#import "_ChannelIO_SDInternalMacros.h"

UIImage * _Nullable _ChannelIO_SDImageCacheDecodeImageData(NSData * _Nonnull imageData, NSString * _Nonnull cacheKey, _ChannelIO_SDWebImageOptions options, _ChannelIO_SDWebImageContext * _Nullable context) {
    UIImage *image;
    BOOL decodeFirstFrame = SD_OPTIONS_CONTAINS(options, SDWebImageDecodeFirstFrameOnly);
    NSNumber *scaleValue = context[_ChannelIO_SDWebImageContextImageScaleFactor];
    CGFloat scale = scaleValue.doubleValue >= 1 ? scaleValue.doubleValue : _ChannelIO_SDImageScaleFactorForKey(cacheKey);
    NSNumber *preserveAspectRatioValue = context[_ChannelIO_SDWebImageContextImagePreserveAspectRatio];
    NSValue *thumbnailSizeValue;
    BOOL shouldScaleDown = SD_OPTIONS_CONTAINS(options, SDWebImageScaleDownLargeImages);
    if (shouldScaleDown) {
        CGFloat thumbnailPixels = _ChannelIO_SDImageCoderHelper.defaultScaleDownLimitBytes / 4;
        CGFloat dimension = ceil(sqrt(thumbnailPixels));
        thumbnailSizeValue = @(CGSizeMake(dimension, dimension));
    }
    if (context[_ChannelIO_SDWebImageContextImageThumbnailPixelSize]) {
        thumbnailSizeValue = context[_ChannelIO_SDWebImageContextImageThumbnailPixelSize];
    }
    
    _ChannelIO_SDImageCoderMutableOptions *mutableCoderOptions = [NSMutableDictionary dictionaryWithCapacity:2];
    mutableCoderOptions[_ChannelIO_SDImageCoderDecodeFirstFrameOnly] = @(decodeFirstFrame);
    mutableCoderOptions[_ChannelIO_SDImageCoderDecodeScaleFactor] = @(scale);
    mutableCoderOptions[_ChannelIO_SDImageCoderDecodePreserveAspectRatio] = preserveAspectRatioValue;
    mutableCoderOptions[_ChannelIO_SDImageCoderDecodeThumbnailPixelSize] = thumbnailSizeValue;
    mutableCoderOptions[_ChannelIO_SDImageCoderWebImageContext] = context;
    _ChannelIO_SDImageCoderOptions *coderOptions = [mutableCoderOptions copy];
    
    // Grab the image coder
    id<_ChannelIO_SDImageCoder> imageCoder;
    if ([context[_ChannelIO_SDWebImageContextImageCoder] conformsToProtocol:@protocol(_ChannelIO_SDImageCoder)]) {
        imageCoder = context[_ChannelIO_SDWebImageContextImageCoder];
    } else {
        imageCoder = [_ChannelIO_SDImageCodersManager sharedManager];
    }
    
    if (!decodeFirstFrame) {
        Class animatedImageClass = context[_ChannelIO_SDWebImageContextAnimatedImageClass];
        // check whether we should use `SDAnimatedImage`
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(_ChannelIO_SDAnimatedImage)]) {
            image = [[animatedImageClass alloc] initWithData:imageData scale:scale options:coderOptions];
            if (image) {
                // Preload frames if supported
                if (options & SDWebImagePreloadAllFrames && [image respondsToSelector:@selector(preloadAllFrames)]) {
                    [((id<_ChannelIO_SDAnimatedImage>)image) preloadAllFrames];
                }
            } else {
                // Check image class matching
                if (options & SDWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        image = [imageCoder decodedImageWithData:imageData options:coderOptions];
    }
    if (image) {
        BOOL shouldDecode = !SD_OPTIONS_CONTAINS(options, SDWebImageAvoidDecodeImage);
        if ([image.class conformsToProtocol:@protocol(_ChannelIO_SDAnimatedImage)]) {
            // `SDAnimatedImage` do not decode
            shouldDecode = NO;
        } else if (image._ChannelIO_sd_isAnimated) {
            // animated image do not decode
            shouldDecode = NO;
        }
        if (shouldDecode) {
            image = [_ChannelIO_SDImageCoderHelper decodedImageWithImage:image];
        }
    }
    
    return image;
}
