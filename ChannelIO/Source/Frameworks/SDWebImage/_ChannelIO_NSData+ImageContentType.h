/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "_ChannelIO_SDWebImageCompat.h"

/**
 You can use switch case like normal enum. It's also recommended to add a default case. You should not assume anything about the raw value.
 For custom coder plugin, it can also extern the enum for supported format. See `SDImageCoder` for more detailed information.
 */
typedef NSInteger _ChannelIO_SDImageFormat NS_TYPED_EXTENSIBLE_ENUM;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatUndefined = -1;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatJPEG      = 0;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatPNG       = 1;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatGIF       = 2;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatTIFF      = 3;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatWebP      = 4;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatHEIC      = 5;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatHEIF      = 6;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatPDF       = 7;
static const _ChannelIO_SDImageFormat _ChannelIO_SDImageFormatSVG       = 8;

/**
 NSData category about the image content type and UTI.
 */
@interface NSData (_ChannelIO_ImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `SDImageFormat` (enum)
 */
+ (_ChannelIO_SDImageFormat)_ChannelIO_sd_imageFormatForImageData:(nullable NSData *)data;

/**
 *  Convert SDImageFormat to UTType
 *
 *  @param format Format as SDImageFormat
 *  @return The UTType as CFStringRef
 *  @note For unknown format, `kUTTypeImage` abstract type will return
 */
+ (nonnull CFStringRef)_ChannelIO_sd_UTTypeFromImageFormat:(_ChannelIO_SDImageFormat)format CF_RETURNS_NOT_RETAINED NS_SWIFT_NAME(sd_UTType(from:));

/**
 *  Convert UTType to SDImageFormat
 *
 *  @param uttype The UTType as CFStringRef
 *  @return The Format as SDImageFormat
 *  @note For unknown type, `SDImageFormatUndefined` will return
 */
+ (_ChannelIO_SDImageFormat)_ChannelIO_sd_imageFormatFromUTType:(nonnull CFStringRef)uttype;

@end
