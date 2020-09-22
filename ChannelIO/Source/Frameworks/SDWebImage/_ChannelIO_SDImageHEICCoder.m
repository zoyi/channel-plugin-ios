/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "_ChannelIO_SDImageHEICCoder.h"
#import "_ChannelIO_SDImageIOAnimatedCoderInternal.h"

// These constants are available from iOS 13+ and Xcode 11. This raw value is used for toolchain and firmware compatibility
static NSString * _ChannelIO_kSDCGImagePropertyHEICSDictionary = @"{HEICS}";
static NSString * _ChannelIO_kSDCGImagePropertyHEICSLoopCount = @"LoopCount";
static NSString * _ChannelIO_kSDCGImagePropertyHEICSDelayTime = @"DelayTime";
static NSString * _ChannelIO_kSDCGImagePropertyHEICSUnclampedDelayTime = @"UnclampedDelayTime";

@implementation _ChannelIO_SDImageHEICCoder

+ (void)initialize {
#if __IPHONE_13_0 || __TVOS_13_0 || __MAC_10_15 || __WATCHOS_6_0
    // Xcode 11
    if (@available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *)) {
        // Use SDK instead of raw value
        _ChannelIO_kSDCGImagePropertyHEICSDictionary = (__bridge NSString *)kCGImagePropertyHEICSDictionary;
        _ChannelIO_kSDCGImagePropertyHEICSLoopCount = (__bridge NSString *)kCGImagePropertyHEICSLoopCount;
        _ChannelIO_kSDCGImagePropertyHEICSDelayTime = (__bridge NSString *)kCGImagePropertyHEICSDelayTime;
        _ChannelIO_kSDCGImagePropertyHEICSUnclampedDelayTime = (__bridge NSString *)kCGImagePropertyHEICSUnclampedDelayTime;
    }
#endif
}

+ (instancetype)sharedCoder {
    static _ChannelIO_SDImageHEICCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[_ChannelIO_SDImageHEICCoder alloc] init];
    });
    return coder;
}

#pragma mark - SDImageCoder

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData _ChannelIO_sd_imageFormatForImageData:data]) {
        case _ChannelIO_SDImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [self.class canDecodeFromFormat:_ChannelIO_SDImageFormatHEIC];
        case _ChannelIO_SDImageFormatHEIF:
            // Check HEIF decoding compatibility
            return [self.class canDecodeFromFormat:_ChannelIO_SDImageFormatHEIF];
        default:
            return NO;
    }
}

- (BOOL)canIncrementalDecodeFromData:(NSData *)data {
    return [self canDecodeFromData:data];
}

- (BOOL)canEncodeToFormat:(_ChannelIO_SDImageFormat)format {
    switch (format) {
        case _ChannelIO_SDImageFormatHEIC:
            // Check HEIC encoding compatibility
            return [self.class canEncodeToFormat:_ChannelIO_SDImageFormatHEIC];
        case _ChannelIO_SDImageFormatHEIF:
            // Check HEIF encoding compatibility
            return [self.class canEncodeToFormat:_ChannelIO_SDImageFormatHEIF];
        default:
            return NO;
    }
}

#pragma mark - Subclass Override

+ (_ChannelIO_SDImageFormat)imageFormat {
    return _ChannelIO_SDImageFormatHEIC;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kSDUTTypeHEIC;
}

+ (NSString *)dictionaryProperty {
    return _ChannelIO_kSDCGImagePropertyHEICSDictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return _ChannelIO_kSDCGImagePropertyHEICSUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return _ChannelIO_kSDCGImagePropertyHEICSDelayTime;
}

+ (NSString *)loopCountProperty {
    return _ChannelIO_kSDCGImagePropertyHEICSLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 0;
}

@end
