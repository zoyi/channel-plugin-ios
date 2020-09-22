/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIImage+Metadata.h"
#import "_ChannelIO_NSImage+Compatibility.h"
#import "_ChannelIO_SDInternalMacros.h"
#import "objc/runtime.h"

@implementation UIImage (_ChannelIO_Metadata)

#if SD_UIKIT || SD_WATCH

- (NSUInteger)_ChannelIO_sd_imageLoopCount {
    NSUInteger imageLoopCount = 0;
    NSNumber *value = objc_getAssociatedObject(self, @selector(_ChannelIO_sd_imageLoopCount));
    if ([value isKindOfClass:[NSNumber class]]) {
        imageLoopCount = value.unsignedIntegerValue;
    }
    return imageLoopCount;
}

- (void)set_ChannelIO_sd_imageLoopCount:(NSUInteger)sd_imageLoopCount {
    NSNumber *value = @(sd_imageLoopCount);
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_imageLoopCount), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)_ChannelIO_sd_isAnimated {
    return (self.images != nil);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (BOOL)_ChannelIO_sd_isVector {
    if (@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)) {
        // Xcode 11 supports symbol image, keep Xcode 10 compatible currently
        SEL SymbolSelector = NSSelectorFromString(@"isSymbolImage");
        if ([self respondsToSelector:SymbolSelector] && [self performSelector:SymbolSelector]) {
            return YES;
        }
        // SVG
        SEL SVGSelector = SD_SEL_SPI(CGSVGDocument);
        if ([self respondsToSelector:SVGSelector] && [self performSelector:SVGSelector]) {
            return YES;
        }
    }
    if (@available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)) {
        // PDF
        SEL PDFSelector = SD_SEL_SPI(CGPDFPage);
        if ([self respondsToSelector:PDFSelector] && [self performSelector:PDFSelector]) {
            return YES;
        }
    }
    return NO;
}
#pragma clang diagnostic pop

#else

- (NSUInteger)_ChannelIO_sd_imageLoopCount {
    NSUInteger imageLoopCount = 0;
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    NSBitmapImageRep *bitmapImageRep;
    if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
        bitmapImageRep = (NSBitmapImageRep *)imageRep;
    }
    if (bitmapImageRep) {
        imageLoopCount = [[bitmapImageRep valueForProperty:NSImageLoopCount] unsignedIntegerValue];
    }
    return imageLoopCount;
}

- (void)set_ChannelIO_sd_imageLoopCount:(NSUInteger)sd_imageLoopCount {
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    NSBitmapImageRep *bitmapImageRep;
    if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
        bitmapImageRep = (NSBitmapImageRep *)imageRep;
    }
    if (bitmapImageRep) {
        [bitmapImageRep setProperty:NSImageLoopCount withValue:@(sd_imageLoopCount)];
    }
}

- (BOOL)_ChannelIO_sd_isAnimated {
    BOOL isAnimated = NO;
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    NSBitmapImageRep *bitmapImageRep;
    if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
        bitmapImageRep = (NSBitmapImageRep *)imageRep;
    }
    if (bitmapImageRep) {
        NSUInteger frameCount = [[bitmapImageRep valueForProperty:NSImageFrameCount] unsignedIntegerValue];
        isAnimated = frameCount > 1 ? YES : NO;
    }
    return isAnimated;
}

- (BOOL)_ChannelIO_sd_isVector {
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSImageRep *imageRep = [self bestRepresentationForRect:imageRect context:nil hints:nil];
    if ([imageRep isKindOfClass:[NSPDFImageRep class]]) {
        return YES;
    }
    if ([imageRep isKindOfClass:[NSEPSImageRep class]]) {
        return YES;
    }
    if ([NSStringFromClass(imageRep.class) hasSuffix:@"NSSVGImageRep"]) {
        return YES;
    }
    return NO;
}

#endif

- (_ChannelIO_SDImageFormat)_ChannelIO_sd_imageFormat {
    _ChannelIO_SDImageFormat imageFormat = _ChannelIO_SDImageFormatUndefined;
    NSNumber *value = objc_getAssociatedObject(self, @selector(_ChannelIO_sd_imageFormat));
    if ([value isKindOfClass:[NSNumber class]]) {
        imageFormat = value.integerValue;
        return imageFormat;
    }
    // Check CGImage's UTType, may return nil for non-Image/IO based image
    if (@available(iOS 9.0, tvOS 9.0, macOS 10.11, watchOS 2.0, *)) {
        CFStringRef uttype = CGImageGetUTType(self.CGImage);
        imageFormat = [NSData _ChannelIO_sd_imageFormatFromUTType:uttype];
    }
    return imageFormat;
}

- (void)set_ChannelIO_sd_imageFormat:(_ChannelIO_SDImageFormat)sd_imageFormat {
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_imageFormat), @(sd_imageFormat), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)set_ChannelIO_sd_isIncremental:(BOOL)sd_isIncremental {
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_isIncremental), @(sd_isIncremental), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)_ChannelIO_sd_isIncremental {
    NSNumber *value = objc_getAssociatedObject(self, @selector(_ChannelIO_sd_isIncremental));
    return value.boolValue;
}

@end
