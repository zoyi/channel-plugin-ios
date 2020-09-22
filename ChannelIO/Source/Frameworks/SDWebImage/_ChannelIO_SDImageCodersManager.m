/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDImageCodersManager.h"
#import "_ChannelIO_SDImageIOCoder.h"
#import "_ChannelIO_SDImageGIFCoder.h"
#import "_ChannelIO_SDImageAPNGCoder.h"
#import "_ChannelIO_SDImageHEICCoder.h"
#import "_ChannelIO_SDInternalMacros.h"

@interface _ChannelIO_SDImageCodersManager ()

@property (nonatomic, strong, nonnull) dispatch_semaphore_t codersLock;

@end

@implementation _ChannelIO_SDImageCodersManager
{
    NSMutableArray<id<_ChannelIO_SDImageCoder>> *_imageCoders;
}

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // initialize with default coders
        _imageCoders = [NSMutableArray arrayWithArray:@[[_ChannelIO_SDImageIOCoder sharedCoder], [_ChannelIO_SDImageGIFCoder sharedCoder], [_ChannelIO_SDImageAPNGCoder sharedCoder]]];
        _codersLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSArray<id<_ChannelIO_SDImageCoder>> *)coders
{
    SD_LOCK(self.codersLock);
    NSArray<id<_ChannelIO_SDImageCoder>> *coders = [_imageCoders copy];
    SD_UNLOCK(self.codersLock);
    return coders;
}

- (void)setCoders:(NSArray<id<_ChannelIO_SDImageCoder>> *)coders
{
    SD_LOCK(self.codersLock);
    [_imageCoders removeAllObjects];
    if (coders.count) {
        [_imageCoders addObjectsFromArray:coders];
    }
    SD_UNLOCK(self.codersLock);
}

#pragma mark - Coder IO operations

- (void)addCoder:(nonnull id<_ChannelIO_SDImageCoder>)coder {
    if (![coder conformsToProtocol:@protocol(_ChannelIO_SDImageCoder)]) {
        return;
    }
    SD_LOCK(self.codersLock);
    [_imageCoders addObject:coder];
    SD_UNLOCK(self.codersLock);
}

- (void)removeCoder:(nonnull id<_ChannelIO_SDImageCoder>)coder {
    if (![coder conformsToProtocol:@protocol(_ChannelIO_SDImageCoder)]) {
        return;
    }
    SD_LOCK(self.codersLock);
    [_imageCoders removeObject:coder];
    SD_UNLOCK(self.codersLock);
}

#pragma mark - SDImageCoder
- (BOOL)canDecodeFromData:(NSData *)data {
    NSArray<id<_ChannelIO_SDImageCoder>> *coders = self.coders;
    for (id<_ChannelIO_SDImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canEncodeToFormat:(_ChannelIO_SDImageFormat)format {
    NSArray<id<_ChannelIO_SDImageCoder>> *coders = self.coders;
    for (id<_ChannelIO_SDImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(nullable _ChannelIO_SDImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    UIImage *image;
    NSArray<id<_ChannelIO_SDImageCoder>> *coders = self.coders;
    for (id<_ChannelIO_SDImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            image = [coder decodedImageWithData:data options:options];
            break;
        }
    }
    
    return image;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(_ChannelIO_SDImageFormat)format options:(nullable _ChannelIO_SDImageCoderOptions *)options {
    if (!image) {
        return nil;
    }
    NSArray<id<_ChannelIO_SDImageCoder>> *coders = self.coders;
    for (id<_ChannelIO_SDImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return [coder encodedDataWithImage:image format:format options:options];
        }
    }
    return nil;
}

@end
