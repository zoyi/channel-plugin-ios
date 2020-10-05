/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDImageTransformer.h"
#import "_ChannelIO_UIColor+SDHexString.h"
#if SD_UIKIT || SD_MAC
#import <CoreImage/CoreImage.h>
#endif

// Separator for different transformerKey, for example, `image.png` |> flip(YES,NO) |> rotate(pi/4,YES) => 'image-SDImageFlippingTransformer(1,0)-SDImageRotationTransformer(0.78539816339,1).png'
static NSString * const _ChannelIO_SDImageTransformerKeySeparator = @"-";

NSString * _Nullable _ChannelIO_SDTransformedKeyForKey(NSString * _Nullable key, NSString * _Nonnull transformerKey) {
    if (!key || !transformerKey) {
        return nil;
    }
    // Find the file extension
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    if (ext.length > 0) {
        // For non-file URL
        if (keyURL && !keyURL.isFileURL) {
            // keep anything except path (like URL query)
            NSURLComponents *component = [NSURLComponents componentsWithURL:keyURL resolvingAgainstBaseURL:NO];
            component.path = [[[component.path.stringByDeletingPathExtension stringByAppendingString:_ChannelIO_SDImageTransformerKeySeparator] stringByAppendingString:transformerKey] stringByAppendingPathExtension:ext];
            return component.URL.absoluteString;
        } else {
            // file URL
            return [[[key.stringByDeletingPathExtension stringByAppendingString:_ChannelIO_SDImageTransformerKeySeparator] stringByAppendingString:transformerKey] stringByAppendingPathExtension:ext];
        }
    } else {
        return [[key stringByAppendingString:_ChannelIO_SDImageTransformerKeySeparator] stringByAppendingString:transformerKey];
    }
}

NSString * _Nullable _ChannelIO_SDThumbnailedKeyForKey(NSString * _Nullable key, CGSize thumbnailPixelSize, BOOL preserveAspectRatio) {
    NSString *thumbnailKey = [NSString stringWithFormat:@"Thumbnail({%f,%f},%d)", thumbnailPixelSize.width, thumbnailPixelSize.height, preserveAspectRatio];
    return _ChannelIO_SDTransformedKeyForKey(key, thumbnailKey);
}

@interface _ChannelIO_SDImagePipelineTransformer ()

@property (nonatomic, copy, readwrite, nonnull) NSArray<id<_ChannelIO_SDImageTransformer>> *transformers;
@property (nonatomic, copy, readwrite) NSString *transformerKey;

@end

@implementation _ChannelIO_SDImagePipelineTransformer

+ (instancetype)transformerWithTransformers:(NSArray<id<_ChannelIO_SDImageTransformer>> *)transformers {
    _ChannelIO_SDImagePipelineTransformer *transformer = [_ChannelIO_SDImagePipelineTransformer new];
    transformer.transformers = transformers;
    transformer.transformerKey = [[self class] cacheKeyForTransformers:transformers];
    
    return transformer;
}

+ (NSString *)cacheKeyForTransformers:(NSArray<id<_ChannelIO_SDImageTransformer>> *)transformers {
    if (transformers.count == 0) {
        return @"";
    }
    NSMutableArray<NSString *> *cacheKeys = [NSMutableArray arrayWithCapacity:transformers.count];
    [transformers enumerateObjectsUsingBlock:^(id<_ChannelIO_SDImageTransformer>  _Nonnull transformer, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *cacheKey = transformer.transformerKey;
        [cacheKeys addObject:cacheKey];
    }];
    
    return [cacheKeys componentsJoinedByString:_ChannelIO_SDImageTransformerKeySeparator];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    UIImage *transformedImage = image;
    for (id<_ChannelIO_SDImageTransformer> transformer in self.transformers) {
        transformedImage = [transformer transformedImageWithImage:transformedImage forKey:key];
    }
    return transformedImage;
}

@end

@interface _ChannelIO_SDImageRoundCornerTransformer ()

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) SDRectCorner corners;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong, nullable) UIColor *borderColor;

@end

@implementation _ChannelIO_SDImageRoundCornerTransformer

+ (instancetype)transformerWithRadius:(CGFloat)cornerRadius corners:(SDRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    _ChannelIO_SDImageRoundCornerTransformer *transformer = [_ChannelIO_SDImageRoundCornerTransformer new];
    transformer.cornerRadius = cornerRadius;
    transformer.corners = corners;
    transformer.borderWidth = borderWidth;
    transformer.borderColor = borderColor;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"SDImageRoundCornerTransformer(%f,%lu,%f,%@)", self.cornerRadius, (unsigned long)self.corners, self.borderWidth, self.borderColor._ChannelIO_sd_hexString];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image _ChannelIO_sd_roundedCornerImageWithRadius:self.cornerRadius corners:self.corners borderWidth:self.borderWidth borderColor:self.borderColor];
}

@end

@interface _ChannelIO_SDImageResizingTransformer ()

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) _ChannelIO_SDImageScaleMode scaleMode;

@end

@implementation _ChannelIO_SDImageResizingTransformer

+ (instancetype)transformerWithSize:(CGSize)size scaleMode:(_ChannelIO_SDImageScaleMode)scaleMode {
    _ChannelIO_SDImageResizingTransformer *transformer = [_ChannelIO_SDImageResizingTransformer new];
    transformer.size = size;
    transformer.scaleMode = scaleMode;
    
    return transformer;
}

- (NSString *)transformerKey {
    CGSize size = self.size;
    return [NSString stringWithFormat:@"SDImageResizingTransformer({%f,%f},%lu)", size.width, size.height, (unsigned long)self.scaleMode];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image _ChannelIO_sd_resizedImageWithSize:self.size scaleMode:self.scaleMode];
}

@end

@interface _ChannelIO_SDImageCroppingTransformer ()

@property (nonatomic, assign) CGRect rect;

@end

@implementation _ChannelIO_SDImageCroppingTransformer

+ (instancetype)transformerWithRect:(CGRect)rect {
    _ChannelIO_SDImageCroppingTransformer *transformer = [_ChannelIO_SDImageCroppingTransformer new];
    transformer.rect = rect;
    
    return transformer;
}

- (NSString *)transformerKey {
    CGRect rect = self.rect;
    return [NSString stringWithFormat:@"SDImageCroppingTransformer({%f,%f,%f,%f})", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image _ChannelIO_sd_croppedImageWithRect:self.rect];
}

@end

@interface _ChannelIO_SDImageFlippingTransformer ()

@property (nonatomic, assign) BOOL horizontal;
@property (nonatomic, assign) BOOL vertical;

@end

@implementation _ChannelIO_SDImageFlippingTransformer

+ (instancetype)transformerWithHorizontal:(BOOL)horizontal vertical:(BOOL)vertical {
    _ChannelIO_SDImageFlippingTransformer *transformer = [_ChannelIO_SDImageFlippingTransformer new];
    transformer.horizontal = horizontal;
    transformer.vertical = vertical;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"SDImageFlippingTransformer(%d,%d)", self.horizontal, self.vertical];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image _ChannelIO_sd_flippedImageWithHorizontal:self.horizontal vertical:self.vertical];
}

@end

@interface _ChannelIO_SDImageRotationTransformer ()

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) BOOL fitSize;

@end

@implementation _ChannelIO_SDImageRotationTransformer

+ (instancetype)transformerWithAngle:(CGFloat)angle fitSize:(BOOL)fitSize {
    _ChannelIO_SDImageRotationTransformer *transformer = [_ChannelIO_SDImageRotationTransformer new];
    transformer.angle = angle;
    transformer.fitSize = fitSize;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"SDImageRotationTransformer(%f,%d)", self.angle, self.fitSize];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image _ChannelIO_sd_rotatedImageWithAngle:self.angle fitSize:self.fitSize];
}

@end

#pragma mark - Image Blending

@interface _ChannelIO_SDImageTintTransformer ()

@property (nonatomic, strong, nonnull) UIColor *tintColor;

@end

@implementation _ChannelIO_SDImageTintTransformer

+ (instancetype)transformerWithColor:(UIColor *)tintColor {
    _ChannelIO_SDImageTintTransformer *transformer = [_ChannelIO_SDImageTintTransformer new];
    transformer.tintColor = tintColor;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"SDImageTintTransformer(%@)", self.tintColor._ChannelIO_sd_hexString];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image _ChannelIO_sd_tintedImageWithColor:self.tintColor];
}

@end

#pragma mark - Image Effect

@interface _ChannelIO_SDImageBlurTransformer ()

@property (nonatomic, assign) CGFloat blurRadius;

@end

@implementation _ChannelIO_SDImageBlurTransformer

+ (instancetype)transformerWithRadius:(CGFloat)blurRadius {
    _ChannelIO_SDImageBlurTransformer *transformer = [_ChannelIO_SDImageBlurTransformer new];
    transformer.blurRadius = blurRadius;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"SDImageBlurTransformer(%f)", self.blurRadius];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image _ChannelIO_sd_blurredImageWithRadius:self.blurRadius];
}

@end

#if SD_UIKIT || SD_MAC
@interface _ChannelIO_SDImageFilterTransformer ()

@property (nonatomic, strong, nonnull) CIFilter *filter;

@end

@implementation _ChannelIO_SDImageFilterTransformer

+ (instancetype)transformerWithFilter:(CIFilter *)filter {
    _ChannelIO_SDImageFilterTransformer *transformer = [_ChannelIO_SDImageFilterTransformer new];
    transformer.filter = filter;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"SDImageFilterTransformer(%@)", self.filter.name];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image _ChannelIO_sd_filteredImageWithFilter:self.filter];
}

@end
#endif
