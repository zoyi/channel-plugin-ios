/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "_ChannelIO_SDImageAWebPCoder.h"
#import "_ChannelIO_SDImageIOAnimatedCoderInternal.h"

// These constants are available from iOS 14+ and Xcode 12. This raw value is used for toolchain and firmware compatibility
static NSString * _ChannelIO_kSDCGImagePropertyWebPDictionary = @"{WebP}";
static NSString * _ChannelIO_kSDCGImagePropertyWebPLoopCount = @"LoopCount";
static NSString * _ChannelIO_kSDCGImagePropertyWebPDelayTime = @"DelayTime";
static NSString * _ChannelIO_kSDCGImagePropertyWebPUnclampedDelayTime = @"UnclampedDelayTime";

@implementation _ChannelIO_SDImageAWebPCoder

+ (void)initialize {
#if __IPHONE_14_0 || __TVOS_14_0 || __MAC_11_0 || __WATCHOS_7_0
    // Xcode 12
    if (@available(iOS 14, tvOS 14, macOS 11, watchOS 7, *)) {
        // Use SDK instead of raw value
        _ChannelIO_kSDCGImagePropertyWebPDictionary = (__bridge NSString *)_ChannelIO_kCGImagePropertyWebPDictionary;
        _ChannelIO_kSDCGImagePropertyWebPLoopCount = (__bridge NSString *)_ChannelIO_kCGImagePropertyWebPLoopCount;
        _ChannelIO_kSDCGImagePropertyWebPDelayTime = (__bridge NSString *)_ChannelIO_kCGImagePropertyWebPDelayTime;
        _ChannelIO_kSDCGImagePropertyWebPUnclampedDelayTime = (__bridge NSString *)_ChannelIO_kCGImagePropertyWebPUnclampedDelayTime;
    }
#endif
}

+ (instancetype)sharedCoder {
    static _ChannelIO_SDImageAWebPCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[_ChannelIO_SDImageAWebPCoder alloc] init];
    });
    return coder;
}

#pragma mark - SDImageCoder

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData _ChannelIO_sd_imageFormatForImageData:data]) {
        case _ChannelIO_SDImageFormatWebP:
            // Check WebP decoding compatibility
            return [self.class canDecodeFromFormat:_ChannelIO_SDImageFormatWebP];
        default:
            return NO;
    }
}

- (BOOL)canIncrementalDecodeFromData:(NSData *)data {
    return [self canDecodeFromData:data];
}

- (BOOL)canEncodeToFormat:(_ChannelIO_SDImageFormat)format {
    switch (format) {
        case _ChannelIO_SDImageFormatWebP:
            // Check WebP encoding compatibility
            return [self.class canEncodeToFormat:_ChannelIO_SDImageFormatWebP];
        default:
            return NO;
    }
}

#pragma mark - Subclass Override

+ (_ChannelIO_SDImageFormat)imageFormat {
    return _ChannelIO_SDImageFormatWebP;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kSDUTTypeWebP;
}

+ (NSString *)dictionaryProperty {
    return _ChannelIO_kSDCGImagePropertyWebPDictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return _ChannelIO_kSDCGImagePropertyWebPUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return _ChannelIO_kSDCGImagePropertyWebPDelayTime;
}

+ (NSString *)loopCountProperty {
    return _ChannelIO_kSDCGImagePropertyWebPLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 0;
}

@end
