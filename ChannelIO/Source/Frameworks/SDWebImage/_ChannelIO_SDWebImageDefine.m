/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageDefine.h"
#import "_ChannelIO_UIImage+Metadata.h"
#import "_ChannelIO_NSImage+Compatibility.h"
#import "_ChannelIO_SDAssociatedObject.h"

#pragma mark - Image scale

static inline NSArray<NSNumber *> * _Nonnull _ChannelIO_SDImageScaleFactors() {
    return @[@2, @3];
}

inline CGFloat _ChannelIO_SDImageScaleFactorForKey(NSString * _Nullable key) {
    CGFloat scale = 1;
    if (!key) {
        return scale;
    }
    // Check if target OS support scale
#if SD_WATCH
    if ([[WKInterfaceDevice currentDevice] respondsToSelector:@selector(screenScale)])
#elif SD_UIKIT
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
#elif SD_MAC
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)])
#endif
    {
        // a@2x.png -> 8
        if (key.length >= 8) {
            // Fast check
            BOOL isURL = [key hasPrefix:@"http://"] || [key hasPrefix:@"https://"];
            for (NSNumber *scaleFactor in _ChannelIO_SDImageScaleFactors()) {
                // @2x. for file name and normal url
                NSString *fileScale = [NSString stringWithFormat:@"@%@x.", scaleFactor];
                if ([key containsString:fileScale]) {
                    scale = scaleFactor.doubleValue;
                    return scale;
                }
                if (isURL) {
                    // %402x. for url encode
                    NSString *urlScale = [NSString stringWithFormat:@"%%40%@x.", scaleFactor];
                    if ([key containsString:urlScale]) {
                        scale = scaleFactor.doubleValue;
                        return scale;
                    }
                }
            }
        }
    }
    return scale;
}

inline UIImage * _Nullable _ChannelIO_SDScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    CGFloat scale = _ChannelIO_SDImageScaleFactorForKey(key);
    return _ChannelIO_SDScaledImageForScaleFactor(scale, image);
}

inline UIImage * _Nullable _ChannelIO_SDScaledImageForScaleFactor(CGFloat scale, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    if (scale <= 1) {
        return image;
    }
    if (scale == image.scale) {
        return image;
    }
    UIImage *scaledImage;
    if (image._ChannelIO_sd_isAnimated) {
        UIImage *animatedImage;
#if SD_UIKIT || SD_WATCH
        // `UIAnimatedImage` images share the same size and scale.
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            UIImage *tempScaledImage = [[UIImage alloc] initWithCGImage:tempImage.CGImage scale:scale orientation:tempImage.imageOrientation];
            [scaledImages addObject:tempScaledImage];
        }
        
        animatedImage = [UIImage animatedImageWithImages:scaledImages duration:image.duration];
        animatedImage._ChannelIO_sd_imageLoopCount = image._ChannelIO_sd_imageLoopCount;
#else
        // Animated GIF for `NSImage` need to grab `NSBitmapImageRep`;
        NSRect imageRect = NSMakeRect(0, 0, image.size.width, image.size.height);
        NSImageRep *imageRep = [image bestRepresentationForRect:imageRect context:nil hints:nil];
        NSBitmapImageRep *bitmapImageRep;
        if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
            bitmapImageRep = (NSBitmapImageRep *)imageRep;
        }
        if (bitmapImageRep) {
            NSSize size = NSMakeSize(image.size.width / scale, image.size.height / scale);
            animatedImage = [[NSImage alloc] initWithSize:size];
            bitmapImageRep.size = size;
            [animatedImage addRepresentation:bitmapImageRep];
        }
#endif
        scaledImage = animatedImage;
    } else {
#if SD_UIKIT || SD_WATCH
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
#else
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:kCGImagePropertyOrientationUp];
#endif
    }
    _ChannelIO_SDImageCopyAssociatedObject(image, scaledImage);
    
    return scaledImage;
}

#pragma mark - Context option

_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextSetImageOperationKey = @"setImageOperationKey";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextCustomManager = @"customManager";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextImageCache = @"imageCache";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextImageLoader = @"imageLoader";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextImageCoder = @"imageCoder";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextImageTransformer = @"imageTransformer";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextImageScaleFactor = @"imageScaleFactor";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextImagePreserveAspectRatio = @"imagePreserveAspectRatio";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextImageThumbnailPixelSize = @"imageThumbnailPixelSize";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextQueryCacheType = @"queryCacheType";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextStoreCacheType = @"storeCacheType";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextOriginalQueryCacheType = @"originalQueryCacheType";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextOriginalStoreCacheType = @"originalStoreCacheType";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextAnimatedImageClass = @"animatedImageClass";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextDownloadRequestModifier = @"downloadRequestModifier";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextDownloadResponseModifier = @"downloadResponseModifier";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextDownloadDecryptor = @"downloadDecryptor";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextCacheKeyFilter = @"cacheKeyFilter";
_ChannelIO_SDWebImageContextOption const _ChannelIO_SDWebImageContextCacheSerializer = @"cacheSerializer";
