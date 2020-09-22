/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDImageLoader.h"
#import "_ChannelIO_SDWebImageCacheKeyFilter.h"
#import "_ChannelIO_SDImageCodersManager.h"
#import "_ChannelIO_SDImageCoderHelper.h"
#import "_ChannelIO_SDAnimatedImage.h"
#import "_ChannelIO_UIImage+Metadata.h"
#import "_ChannelIO_SDInternalMacros.h"
#import "objc/runtime.h"

static void * _ChannelIO_SDImageLoaderProgressiveCoderKey = &_ChannelIO_SDImageLoaderProgressiveCoderKey;

UIImage * _Nullable _ChannelIO_SDImageLoaderDecodeImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, _ChannelIO_SDWebImageOptions options, _ChannelIO_SDWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    
    UIImage *image;
    id<_ChannelIO_SDWebImageCacheKeyFilter> cacheKeyFilter = context[_ChannelIO_SDWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
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
        // check whether we should use `SDAnimatedImage`
        Class animatedImageClass = context[_ChannelIO_SDWebImageContextAnimatedImageClass];
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

UIImage * _Nullable _ChannelIO_SDImageLoaderDecodeProgressiveImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, BOOL finished,  id<_ChannelIO_SDWebImageOperation> _Nonnull operation, _ChannelIO_SDWebImageOptions options, _ChannelIO_SDWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    NSCParameterAssert(operation);
    
    UIImage *image;
    id<_ChannelIO_SDWebImageCacheKeyFilter> cacheKeyFilter = context[_ChannelIO_SDWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
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
    
    // Grab the progressive image coder
    id<_ChannelIO_SDProgressiveImageCoder> progressiveCoder = objc_getAssociatedObject(operation, _ChannelIO_SDImageLoaderProgressiveCoderKey);
    if (!progressiveCoder) {
        id<_ChannelIO_SDProgressiveImageCoder> imageCoder = context[_ChannelIO_SDWebImageContextImageCoder];
        // Check the progressive coder if provided
        if ([imageCoder conformsToProtocol:@protocol(_ChannelIO_SDProgressiveImageCoder)]) {
            progressiveCoder = [[[imageCoder class] alloc] initIncrementalWithOptions:coderOptions];
        } else {
            // We need to create a new instance for progressive decoding to avoid conflicts
            for (id<_ChannelIO_SDImageCoder> coder in [_ChannelIO_SDImageCodersManager sharedManager].coders.reverseObjectEnumerator) {
                if ([coder conformsToProtocol:@protocol(_ChannelIO_SDProgressiveImageCoder)] &&
                    [((id<_ChannelIO_SDProgressiveImageCoder>)coder) canIncrementalDecodeFromData:imageData]) {
                    progressiveCoder = [[[coder class] alloc] initIncrementalWithOptions:coderOptions];
                    break;
                }
            }
        }
        objc_setAssociatedObject(operation, _ChannelIO_SDImageLoaderProgressiveCoderKey, progressiveCoder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // If we can't find any progressive coder, disable progressive download
    if (!progressiveCoder) {
        return nil;
    }
    
    [progressiveCoder updateIncrementalData:imageData finished:finished];
    if (!decodeFirstFrame) {
        // check whether we should use `SDAnimatedImage`
        Class animatedImageClass = context[_ChannelIO_SDWebImageContextAnimatedImageClass];
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(_ChannelIO_SDAnimatedImage)] && [progressiveCoder conformsToProtocol:@protocol(_ChannelIO_SDAnimatedImageCoder)]) {
            image = [[animatedImageClass alloc] initWithAnimatedCoder:(id<_ChannelIO_SDAnimatedImageCoder>)progressiveCoder scale:scale];
            if (image) {
                // Progressive decoding does not preload frames
            } else {
                // Check image class matching
                if (options & SDWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        image = [progressiveCoder incrementalDecodedImageWithOptions:coderOptions];
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
        // mark the image as progressive (completionBlock one are not mark as progressive)
        image._ChannelIO_sd_isIncremental = YES;
    }
    
    return image;
}

_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextLoaderCachedImage = @"loaderCachedImage";
