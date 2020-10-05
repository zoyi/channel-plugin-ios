/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "_ChannelIO_SDWebImageCompat.h"

#if SD_MAC

#import <QuartzCore/QuartzCore.h>

/// Helper method for Core Animation transition
FOUNDATION_EXPORT CAMediaTimingFunction * _Nullable _ChannelIO_SDTimingFunctionFromAnimationOptions(_ChannelIO_SDWebImageAnimationOptions options);
FOUNDATION_EXPORT CATransition * _Nullable _ChannelIO_SDTransitionFromAnimationOptions(_ChannelIO_SDWebImageAnimationOptions options);

#endif
