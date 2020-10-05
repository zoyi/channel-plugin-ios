/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_NSImage+Compatibility.h"

#if SD_MAC

#import "_ChannelIO_SDImageCoderHelper.h"

@implementation NSImage (_ChannelIO_Compatibility)

- (nullable CGImageRef)_ChannelIO_CGImage {
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    CGImageRef cgImage = [self CGImageForProposedRect:&imageRect context:nil hints:nil];
    return cgImage;
}

- (nullable CIImage *)_ChannelIO_CIImage {
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    if (![imageRep isKindOfClass:NSCIImageRep.class]) {
        return nil;
    }
    return ((NSCIImageRep *)imageRep).CIImage;
}

- (CGFloat)_ChannelIO_scale {
    CGFloat scale = 1;
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    CGFloat width = imageRep.size.width;
    CGFloat height = imageRep.size.height;
    NSUInteger pixelWidth = imageRep.pixelsWide;
    NSUInteger pixelHeight = imageRep.pixelsHigh;
    if (width > 0 && height > 0) {
        CGFloat widthScale = pixelWidth / width;
        CGFloat heightScale = pixelHeight / height;
        if (widthScale == heightScale && widthScale >= 1) {
            // Protect because there may be `NSImageRepMatchesDevice` (0)
            scale = widthScale;
        }
    }
    
    return scale;
}

- (instancetype)_ChannelIO_initWithCGImage:(nonnull CGImageRef)cgImage scale:(CGFloat)scale orientation:(CGImagePropertyOrientation)orientation {
    NSBitmapImageRep *imageRep;
    if (orientation != kCGImagePropertyOrientationUp) {
        // AppKit design is different from UIKit. Where CGImage based image rep does not respect to any orientation. Only data based image rep which contains the EXIF metadata can automatically detect orientation.
        // This should be nonnull, until the memory is exhausted cause `CGBitmapContextCreate` failed.
        CGImageRef rotatedCGImage = [SDImageCoderHelper CGImageCreateDecoded:cgImage orientation:orientation];
        imageRep = [[NSBitmapImageRep alloc] initWithCGImage:rotatedCGImage];
        CGImageRelease(rotatedCGImage);
    } else {
        imageRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    }
    if (scale < 1) {
        scale = 1;
    }
    CGFloat pixelWidth = imageRep.pixelsWide;
    CGFloat pixelHeight = imageRep.pixelsHigh;
    NSSize size = NSMakeSize(pixelWidth / scale, pixelHeight / scale);
    self = [self initWithSize:size];
    if (self) {
        imageRep.size = size;
        [self addRepresentation:imageRep];
    }
    return self;
}

- (instancetype)_ChannelIO_initWithCIImage:(nonnull CIImage *)ciImage scale:(CGFloat)scale orientation:(CGImagePropertyOrientation)orientation {
    NSCIImageRep *imageRep;
    if (orientation != kCGImagePropertyOrientationUp) {
        CIImage *rotatedCIImage = [ciImage imageByApplyingOrientation:orientation];
        imageRep = [[NSCIImageRep alloc] initWithCIImage:rotatedCIImage];
    } else {
        imageRep = [[NSCIImageRep alloc] initWithCIImage:ciImage];
    }
    if (scale < 1) {
        scale = 1;
    }
    CGFloat pixelWidth = imageRep.pixelsWide;
    CGFloat pixelHeight = imageRep.pixelsHigh;
    NSSize size = NSMakeSize(pixelWidth / scale, pixelHeight / scale);
    self = [self initWithSize:size];
    if (self) {
        imageRep.size = size;
        [self addRepresentation:imageRep];
    }
    return self;
}

- (instancetype)_ChannelIO_initWithData:(nonnull NSData *)data scale:(CGFloat)scale {
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:data];
    if (!imageRep) {
        return nil;
    }
    if (scale < 1) {
        scale = 1;
    }
    CGFloat pixelWidth = imageRep.pixelsWide;
    CGFloat pixelHeight = imageRep.pixelsHigh;
    NSSize size = NSMakeSize(pixelWidth / scale, pixelHeight / scale);
    self = [self initWithSize:size];
    if (self) {
        imageRep.size = size;
        [self addRepresentation:imageRep];
    }
    return self;
}

@end

#endif
