/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_NSData+ImageContentType.h"
#if SD_MAC
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif
#import "_ChannelIO_SDImageIOAnimatedCoderInternal.h"

#define kSVGTagEnd @"</svg>"

@implementation NSData (_ChannelIO_ImageContentType)

+ (_ChannelIO_SDImageFormat)_ChannelIO_sd_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return _ChannelIO_SDImageFormatUndefined;
    }
    
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return _ChannelIO_SDImageFormatJPEG;
        case 0x89:
            return _ChannelIO_SDImageFormatPNG;
        case 0x47:
            return _ChannelIO_SDImageFormatGIF;
        case 0x49:
        case 0x4D:
            return _ChannelIO_SDImageFormatTIFF;
        case 0x52: {
            if (data.length >= 12) {
                //RIFF....WEBP
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return _ChannelIO_SDImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return _ChannelIO_SDImageFormatHEIC;
                }
                //....ftypmif1 ....ftypmsf1
                if ([testString isEqualToString:@"ftypmif1"] || [testString isEqualToString:@"ftypmsf1"]) {
                    return _ChannelIO_SDImageFormatHEIF;
                }
            }
            break;
        }
        case 0x25: {
            if (data.length >= 4) {
                //%PDF
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(1, 3)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"PDF"]) {
                    return _ChannelIO_SDImageFormatPDF;
                }
            }
        }
        case 0x3C: {
            // Check end with SVG tag
            if ([data rangeOfData:[kSVGTagEnd dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range: NSMakeRange(data.length - MIN(100, data.length), MIN(100, data.length))].location != NSNotFound) {
                return _ChannelIO_SDImageFormatSVG;
            }
        }
    }
    return _ChannelIO_SDImageFormatUndefined;
}

+ (nonnull CFStringRef)_ChannelIO_sd_UTTypeFromImageFormat:(_ChannelIO_SDImageFormat)format {
    CFStringRef UTType;
    switch (format) {
        case _ChannelIO_SDImageFormatJPEG:
            UTType = kUTTypeJPEG;
            break;
        case _ChannelIO_SDImageFormatPNG:
            UTType = kUTTypePNG;
            break;
        case _ChannelIO_SDImageFormatGIF:
            UTType = kUTTypeGIF;
            break;
        case _ChannelIO_SDImageFormatTIFF:
            UTType = kUTTypeTIFF;
            break;
        case _ChannelIO_SDImageFormatWebP:
            UTType = kSDUTTypeWebP;
            break;
        case _ChannelIO_SDImageFormatHEIC:
            UTType = kSDUTTypeHEIC;
            break;
        case _ChannelIO_SDImageFormatHEIF:
            UTType = kSDUTTypeHEIF;
            break;
        case _ChannelIO_SDImageFormatPDF:
            UTType = kUTTypePDF;
            break;
        case _ChannelIO_SDImageFormatSVG:
            UTType = kUTTypeScalableVectorGraphics;
            break;
        default:
            // default is kUTTypeImage abstract type
            UTType = kUTTypeImage;
            break;
    }
    return UTType;
}

+ (_ChannelIO_SDImageFormat)_ChannelIO_sd_imageFormatFromUTType:(CFStringRef)uttype {
    if (!uttype) {
        return _ChannelIO_SDImageFormatUndefined;
    }
    _ChannelIO_SDImageFormat imageFormat;
    if (CFStringCompare(uttype, kUTTypeJPEG, 0) == kCFCompareEqualTo) {
        imageFormat = _ChannelIO_SDImageFormatJPEG;
    } else if (CFStringCompare(uttype, kUTTypePNG, 0) == kCFCompareEqualTo) {
        imageFormat = _ChannelIO_SDImageFormatPNG;
    } else if (CFStringCompare(uttype, kUTTypeGIF, 0) == kCFCompareEqualTo) {
        imageFormat = _ChannelIO_SDImageFormatGIF;
    } else if (CFStringCompare(uttype, kUTTypeTIFF, 0) == kCFCompareEqualTo) {
        imageFormat = _ChannelIO_SDImageFormatTIFF;
    } else if (CFStringCompare(uttype, kSDUTTypeWebP, 0) == kCFCompareEqualTo) {
        imageFormat = _ChannelIO_SDImageFormatWebP;
    } else if (CFStringCompare(uttype, kSDUTTypeHEIC, 0) == kCFCompareEqualTo) {
        imageFormat = _ChannelIO_SDImageFormatHEIC;
    } else if (CFStringCompare(uttype, kSDUTTypeHEIF, 0) == kCFCompareEqualTo) {
        imageFormat = _ChannelIO_SDImageFormatHEIF;
    } else if (CFStringCompare(uttype, kUTTypePDF, 0) == kCFCompareEqualTo) {
        imageFormat = _ChannelIO_SDImageFormatPDF;
    } else if (CFStringCompare(uttype, kUTTypeScalableVectorGraphics, 0) == kCFCompareEqualTo) {
        imageFormat = _ChannelIO_SDImageFormatSVG;
    } else {
        imageFormat = _ChannelIO_SDImageFormatUndefined;
    }
    return imageFormat;
}

@end
