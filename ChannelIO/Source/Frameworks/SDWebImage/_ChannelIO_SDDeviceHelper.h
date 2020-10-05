/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import <Foundation/Foundation.h>
#import "_ChannelIO_SDWebImageCompat.h"

/// Device information helper methods
@interface _ChannelIO_SDDeviceHelper : NSObject

+ (NSUInteger)totalMemory;
+ (NSUInteger)freeMemory;

@end
