/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
* (c) Fabrice Aneche
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "_ChannelIO_UIImage+ExtendedCacheData.h"
#import <objc/runtime.h>

@implementation UIImage (_ChannelIO_ExtendedCacheData)

- (id<NSObject, NSCoding>)_ChannelIO_sd_extendedObject {
    return objc_getAssociatedObject(self, @selector(_ChannelIO_sd_extendedObject));
}

- (void)set_ChannelIO_sd_extendedObject:(id<NSObject, NSCoding>)sd_extendedObject {
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_extendedObject), sd_extendedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
