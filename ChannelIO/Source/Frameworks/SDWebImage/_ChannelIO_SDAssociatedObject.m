/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "_ChannelIO_SDAssociatedObject.h"
#import "_ChannelIO_UIImage+Metadata.h"
#import "_ChannelIO_UIImage+ExtendedCacheData.h"
#import "_ChannelIO_UIImage+MemoryCacheCost.h"
#import "_ChannelIO_UIImage+ForceDecode.h"

void _ChannelIO_SDImageCopyAssociatedObject(UIImage * _Nullable source, UIImage * _Nullable target) {
    if (!source || !target) {
        return;
    }
    // Image Metadata
    target._ChannelIO_sd_isIncremental = source._ChannelIO_sd_isIncremental;
    target._ChannelIO_sd_imageLoopCount = source._ChannelIO_sd_imageLoopCount;
    target._ChannelIO_sd_imageFormat = source._ChannelIO_sd_imageFormat;
    // Force Decode
    target._ChannelIO_sd_isDecoded = source._ChannelIO_sd_isDecoded;
    // Extended Cache Data
    target._ChannelIO_sd_extendedObject = source._ChannelIO_sd_extendedObject;
}
