/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDImageGIFCoder.h"
#if SD_MAC
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif

@implementation _ChannelIO_SDImageGIFCoder

+ (instancetype)sharedCoder {
    static _ChannelIO_SDImageGIFCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[_ChannelIO_SDImageGIFCoder alloc] init];
    });
    return coder;
}

#pragma mark - Subclass Override

+ (_ChannelIO_SDImageFormat)imageFormat {
    return _ChannelIO_SDImageFormatGIF;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kUTTypeGIF;
}

+ (NSString *)dictionaryProperty {
    return (__bridge NSString *)kCGImagePropertyGIFDictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return (__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return (__bridge NSString *)kCGImagePropertyGIFDelayTime;
}

+ (NSString *)loopCountProperty {
    return (__bridge NSString *)kCGImagePropertyGIFLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 1;
}

@end
