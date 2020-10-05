/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDAnimatedImage.h"
#import "_ChannelIO_NSImage+Compatibility.h"
#import "_ChannelIO_SDImageCoder.h"
#import "_ChannelIO_SDImageCodersManager.h"
#import "_ChannelIO_SDImageFrame.h"
#import "_ChannelIO_UIImage+MemoryCacheCost.h"
#import "_ChannelIO_UIImage+Metadata.h"
#import "_ChannelIO_UIImage+MultiFormat.h"
#import "_ChannelIO_SDImageCoderHelper.h"
#import "_ChannelIO_SDImageAssetManager.h"
#import "objc/runtime.h"

static CGFloat _ChannelIO_SDImageScaleFromPath(NSString *string) {
    if (string.length == 0 || [string hasSuffix:@"/"]) return 1;
    NSString *name = string.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    [pattern enumerateMatchesInString:name options:kNilOptions range:NSMakeRange(0, name.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        scale = [string substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)].doubleValue;
    }];
    
    return scale;
}

@interface _ChannelIO_SDAnimatedImage ()

@property (nonatomic, strong) id<_ChannelIO_SDAnimatedImageCoder> animatedCoder;
@property (nonatomic, assign, readwrite) _ChannelIO_SDImageFormat animatedImageFormat;
@property (atomic, copy) NSArray<_ChannelIO_SDImageFrame *> *loadedAnimatedImageFrames; // Mark as atomic to keep thread-safe
@property (nonatomic, assign, getter=isAllFramesLoaded) BOOL allFramesLoaded;

@end

@implementation _ChannelIO_SDAnimatedImage
@dynamic scale; // call super

#pragma mark - UIImage override method
+ (instancetype)imageNamed:(NSString *)name {
#if __has_include(<UIKit/UITraitCollection.h>)
    return [self imageNamed:name inBundle:nil compatibleWithTraitCollection:nil];
#else
    return [self imageNamed:name inBundle:nil];
#endif
}

#if __has_include(<UIKit/UITraitCollection.h>)
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle compatibleWithTraitCollection:(UITraitCollection *)traitCollection {
    if (!traitCollection) {
        traitCollection = UIScreen.mainScreen.traitCollection;
    }
    CGFloat scale = traitCollection.displayScale;
    return [self imageNamed:name inBundle:bundle scale:scale];
}
#else
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    return [self imageNamed:name inBundle:bundle scale:0];
}
#endif

// 0 scale means automatically check
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle scale:(CGFloat)scale {
    if (!name) {
        return nil;
    }
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    _ChannelIO_SDImageAssetManager *assetManager = [_ChannelIO_SDImageAssetManager sharedAssetManager];
    _ChannelIO_SDAnimatedImage *image = (_ChannelIO_SDAnimatedImage *)[assetManager imageForName:name];
    if ([image isKindOfClass:[_ChannelIO_SDAnimatedImage class]]) {
        return image;
    }
    NSString *path = [assetManager getPathForName:name bundle:bundle preferredScale:&scale];
    if (!path) {
        return image;
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return image;
    }
    image = [[self alloc] initWithData:data scale:scale];
    if (image) {
        [assetManager storeImage:image forName:name];
    }
    
    return image;
}

+ (instancetype)imageWithContentsOfFile:(NSString *)path {
    return [[self alloc] initWithContentsOfFile:path];
}

+ (instancetype)imageWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

+ (instancetype)imageWithData:(NSData *)data scale:(CGFloat)scale {
    return [[self alloc] initWithData:data scale:scale];
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self initWithData:data scale:_ChannelIO_SDImageScaleFromPath(path)];
}

- (instancetype)initWithData:(NSData *)data {
    return [self initWithData:data scale:1];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale {
    return [self initWithData:data scale:scale options:nil];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale options:(_ChannelIO_SDImageCoderOptions *)options {
    if (!data || data.length == 0) {
        return nil;
    }
    data = [data copy]; // avoid mutable data
    id<_ChannelIO_SDAnimatedImageCoder> animatedCoder = nil;
    for (id<_ChannelIO_SDImageCoder>coder in [_ChannelIO_SDImageCodersManager sharedManager].coders) {
        if ([coder conformsToProtocol:@protocol(_ChannelIO_SDAnimatedImageCoder)]) {
            if ([coder canDecodeFromData:data]) {
                if (!options) {
                    options = @{_ChannelIO_SDImageCoderDecodeScaleFactor : @(scale)};
                }
                animatedCoder = [[[coder class] alloc] initWithAnimatedImageData:data options:options];
                break;
            }
        }
    }
    if (!animatedCoder) {
        return nil;
    }
    return [self initWithAnimatedCoder:animatedCoder scale:scale];
}

- (instancetype)initWithAnimatedCoder:(id<_ChannelIO_SDAnimatedImageCoder>)animatedCoder scale:(CGFloat)scale {
    if (!animatedCoder) {
        return nil;
    }
    UIImage *image = [animatedCoder animatedImageFrameAtIndex:0];
    if (!image) {
        return nil;
    }
#if SD_MAC
    self = [super initWithCGImage:image.CGImage scale:MAX(scale, 1) orientation:kCGImagePropertyOrientationUp];
#else
    self = [super initWithCGImage:image.CGImage scale:MAX(scale, 1) orientation:image.imageOrientation];
#endif
    if (self) {
        // Only keep the animated coder if frame count > 1, save RAM usage for non-animated image format (APNG/WebP)
        if (animatedCoder.animatedImageFrameCount > 1) {
            _animatedCoder = animatedCoder;
        }
        NSData *data = [animatedCoder animatedImageData];
        _ChannelIO_SDImageFormat format = [NSData _ChannelIO_sd_imageFormatForImageData:data];
        _animatedImageFormat = format;
    }
    return self;
}

#pragma mark - Preload
- (void)preloadAllFrames {
    if (!_animatedCoder) {
        return;
    }
    if (!self.isAllFramesLoaded) {
        NSMutableArray<_ChannelIO_SDImageFrame *> *frames = [NSMutableArray arrayWithCapacity:self.animatedImageFrameCount];
        for (size_t i = 0; i < self.animatedImageFrameCount; i++) {
            UIImage *image = [self animatedImageFrameAtIndex:i];
            NSTimeInterval duration = [self animatedImageDurationAtIndex:i];
            _ChannelIO_SDImageFrame *frame = [_ChannelIO_SDImageFrame frameWithImage:image duration:duration]; // through the image should be nonnull, used as nullable for `animatedImageFrameAtIndex:`
            [frames addObject:frame];
        }
        self.loadedAnimatedImageFrames = frames;
        self.allFramesLoaded = YES;
    }
}

- (void)unloadAllFrames {
    if (!_animatedCoder) {
        return;
    }
    if (self.isAllFramesLoaded) {
        self.loadedAnimatedImageFrames = nil;
        self.allFramesLoaded = NO;
    }
}

#pragma mark - NSSecureCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _animatedImageFormat = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(animatedImageFormat))];
        NSData *animatedImageData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(animatedImageData))];
        if (!animatedImageData) {
            return self;
        }
        CGFloat scale = self.scale;
        id<_ChannelIO_SDAnimatedImageCoder> animatedCoder = nil;
        for (id<_ChannelIO_SDImageCoder>coder in [_ChannelIO_SDImageCodersManager sharedManager].coders) {
            if ([coder conformsToProtocol:@protocol(_ChannelIO_SDAnimatedImageCoder)]) {
                if ([coder canDecodeFromData:animatedImageData]) {
                    animatedCoder = [[[coder class] alloc] initWithAnimatedImageData:animatedImageData options:@{_ChannelIO_SDImageCoderDecodeScaleFactor : @(scale)}];
                    break;
                }
            }
        }
        if (!animatedCoder) {
            return self;
        }
        if (animatedCoder.animatedImageFrameCount > 1) {
            _animatedCoder = animatedCoder;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.animatedImageFormat forKey:NSStringFromSelector(@selector(animatedImageFormat))];
    NSData *animatedImageData = self.animatedImageData;
    if (animatedImageData) {
        [aCoder encodeObject:animatedImageData forKey:NSStringFromSelector(@selector(animatedImageData))];
    }
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - SDAnimatedImageProvider

- (NSData *)animatedImageData {
    return [self.animatedCoder animatedImageData];
}

- (NSUInteger)animatedImageLoopCount {
    return [self.animatedCoder animatedImageLoopCount];
}

- (NSUInteger)animatedImageFrameCount {
    return [self.animatedCoder animatedImageFrameCount];
}

- (UIImage *)animatedImageFrameAtIndex:(NSUInteger)index {
    if (index >= self.animatedImageFrameCount) {
        return nil;
    }
    if (self.isAllFramesLoaded) {
        _ChannelIO_SDImageFrame *frame = [self.loadedAnimatedImageFrames objectAtIndex:index];
        return frame.image;
    }
    return [self.animatedCoder animatedImageFrameAtIndex:index];
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index {
    if (index >= self.animatedImageFrameCount) {
        return 0;
    }
    if (self.isAllFramesLoaded) {
        _ChannelIO_SDImageFrame *frame = [self.loadedAnimatedImageFrames objectAtIndex:index];
        return frame.duration;
    }
    return [self.animatedCoder animatedImageDurationAtIndex:index];
}

@end

@implementation _ChannelIO_SDAnimatedImage (_ChannelIO_MemoryCacheCost)

- (NSUInteger)sd_memoryCost {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sd_memoryCost));
    if (value != nil) {
        return value.unsignedIntegerValue;
    }
    
    CGImageRef imageRef = self.CGImage;
    if (!imageRef) {
        return 0;
    }
    NSUInteger bytesPerFrame = CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef);
    NSUInteger frameCount = 1;
    if (self.isAllFramesLoaded) {
        frameCount = self.animatedImageFrameCount;
    }
    frameCount = frameCount > 0 ? frameCount : 1;
    NSUInteger cost = bytesPerFrame * frameCount;
    return cost;
}

@end

@implementation _ChannelIO_SDAnimatedImage (Metadata)

- (BOOL)sd_isAnimated {
    return YES;
}

- (NSUInteger)sd_imageLoopCount {
    return self.animatedImageLoopCount;
}

- (void)setSd_imageLoopCount:(NSUInteger)sd_imageLoopCount {
    return;
}

- (_ChannelIO_SDImageFormat)sd_imageFormat {
    return self.animatedImageFormat;
}

- (void)setSd_imageFormat:(_ChannelIO_SDImageFormat)sd_imageFormat {
    return;
}

- (BOOL)sd_isVector {
    return NO;
}

@end

@implementation _ChannelIO_SDAnimatedImage (_ChannelIO_MultiFormat)

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data {
    return [self sd_imageWithData:data scale:1];
}

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale {
    return [self sd_imageWithData:data scale:scale firstFrameOnly:NO];
}

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data scale:(CGFloat)scale firstFrameOnly:(BOOL)firstFrameOnly {
    if (!data) {
        return nil;
    }
    return [[self alloc] initWithData:data scale:scale options:@{_ChannelIO_SDImageCoderDecodeFirstFrameOnly : @(firstFrameOnly)}];
}

- (nullable NSData *)sd_imageData {
    NSData *imageData = self.animatedImageData;
    if (imageData) {
        return imageData;
    } else {
        return [self sd_imageDataAsFormat:self.animatedImageFormat];
    }
}

- (nullable NSData *)sd_imageDataAsFormat:(_ChannelIO_SDImageFormat)imageFormat {
    return [self sd_imageDataAsFormat:imageFormat compressionQuality:1];
}

- (nullable NSData *)sd_imageDataAsFormat:(_ChannelIO_SDImageFormat)imageFormat compressionQuality:(double)compressionQuality {
    return [self sd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:NO];
}

- (nullable NSData *)sd_imageDataAsFormat:(_ChannelIO_SDImageFormat)imageFormat compressionQuality:(double)compressionQuality firstFrameOnly:(BOOL)firstFrameOnly {
    if (firstFrameOnly) {
        // First frame, use super implementation
        return [super _ChannelIO_sd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:firstFrameOnly];
    }
    NSUInteger frameCount = self.animatedImageFrameCount;
    if (frameCount <= 1) {
        // Static image, use super implementation
        return [super _ChannelIO_sd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:firstFrameOnly];
    }
    // Keep animated image encoding, loop each frame.
    NSMutableArray<_ChannelIO_SDImageFrame *> *frames = [NSMutableArray arrayWithCapacity:frameCount];
    for (size_t i = 0; i < frameCount; i++) {
        UIImage *image = [self animatedImageFrameAtIndex:i];
        NSTimeInterval duration = [self animatedImageDurationAtIndex:i];
        _ChannelIO_SDImageFrame *frame = [_ChannelIO_SDImageFrame frameWithImage:image duration:duration];
        [frames addObject:frame];
    }
    UIImage *animatedImage = [_ChannelIO_SDImageCoderHelper animatedImageWithFrames:frames];
    NSData *imageData = [animatedImage _ChannelIO_sd_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:firstFrameOnly];
    return imageData;
}

@end
