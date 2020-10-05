/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageTransition.h"

#if SD_UIKIT || SD_MAC

#if SD_MAC
#import "_ChannelIO_SDWebImageTransitionInternal.h"
#import "_ChannelIO_SDInternalMacros.h"

CAMediaTimingFunction * _ChannelIO_SDTimingFunctionFromAnimationOptions(_ChannelIO_SDWebImageAnimationOptions options) {
    if (SD_OPTIONS_CONTAINS(SDWebImageAnimationOptionCurveLinear, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    } else if (SD_OPTIONS_CONTAINS(SDWebImageAnimationOptionCurveEaseIn, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    } else if (SD_OPTIONS_CONTAINS(SDWebImageAnimationOptionCurveEaseOut, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    } else if (SD_OPTIONS_CONTAINS(SDWebImageAnimationOptionCurveEaseInOut, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    } else {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    }
}

CATransition * _ChannelIO_SDTransitionFromAnimationOptions(_ChannelIO_SDWebImageAnimationOptions options) {
    if (SD_OPTIONS_CONTAINS(options, SDWebImageAnimationOptionTransitionCrossDissolve)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionFade;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, SDWebImageAnimationOptionTransitionFlipFromLeft)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromLeft;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, SDWebImageAnimationOptionTransitionFlipFromRight)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromRight;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, SDWebImageAnimationOptionTransitionFlipFromTop)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromTop;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, SDWebImageAnimationOptionTransitionFlipFromBottom)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromBottom;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, SDWebImageAnimationOptionTransitionCurlUp)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromTop;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, SDWebImageAnimationOptionTransitionCurlDown)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromBottom;
        return trans;
    } else {
        return nil;
    }
}
#endif

@implementation _ChannelIO_SDWebImageTransition

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 0.5;
    }
    return self;
}

@end

@implementation _ChannelIO_SDWebImageTransition (Conveniences)

+ (_ChannelIO_SDWebImageTransition *)fadeTransition {
    return [self fadeTransitionWithDuration:0.5];
}

+ (_ChannelIO_SDWebImageTransition *)fadeTransitionWithDuration:(NSTimeInterval)duration {
    _ChannelIO_SDWebImageTransition *transition = [_ChannelIO_SDWebImageTransition new];
#if SD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionCrossDissolve;
#endif
    return transition;
}

+ (_ChannelIO_SDWebImageTransition *)flipFromLeftTransition {
    return [self flipFromLeftTransitionWithDuration:0.5];
}

+ (_ChannelIO_SDWebImageTransition *)flipFromLeftTransitionWithDuration:(NSTimeInterval)duration {
    _ChannelIO_SDWebImageTransition *transition = [_ChannelIO_SDWebImageTransition new];
#if SD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionFlipFromLeft;
#endif
    return transition;
}

+ (_ChannelIO_SDWebImageTransition *)flipFromRightTransition {
    return [self flipFromRightTransitionWithDuration:0.5];
}

+ (_ChannelIO_SDWebImageTransition *)flipFromRightTransitionWithDuration:(NSTimeInterval)duration {
    _ChannelIO_SDWebImageTransition *transition = [_ChannelIO_SDWebImageTransition new];
#if SD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionFlipFromRight;
#endif
    return transition;
}

+ (_ChannelIO_SDWebImageTransition *)flipFromTopTransition {
    return [self flipFromTopTransitionWithDuration:0.5];
}

+ (_ChannelIO_SDWebImageTransition *)flipFromTopTransitionWithDuration:(NSTimeInterval)duration {
    _ChannelIO_SDWebImageTransition *transition = [_ChannelIO_SDWebImageTransition new];
#if SD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromTop | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionFlipFromTop;
#endif
    return transition;
}

+ (_ChannelIO_SDWebImageTransition *)flipFromBottomTransition {
    return [self flipFromBottomTransitionWithDuration:0.5];
}

+ (_ChannelIO_SDWebImageTransition *)flipFromBottomTransitionWithDuration:(NSTimeInterval)duration {
    _ChannelIO_SDWebImageTransition *transition = [_ChannelIO_SDWebImageTransition new];
#if SD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromBottom | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionFlipFromBottom;
#endif
    return transition;
}

+ (_ChannelIO_SDWebImageTransition *)curlUpTransition {
    return [self curlUpTransitionWithDuration:0.5];
}

+ (_ChannelIO_SDWebImageTransition *)curlUpTransitionWithDuration:(NSTimeInterval)duration {
    _ChannelIO_SDWebImageTransition *transition = [_ChannelIO_SDWebImageTransition new];
#if SD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlUp | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionCurlUp;
#endif
    return transition;
}

+ (_ChannelIO_SDWebImageTransition *)curlDownTransition {
    return [self curlDownTransitionWithDuration:0.5];
}

+ (_ChannelIO_SDWebImageTransition *)curlDownTransitionWithDuration:(NSTimeInterval)duration {
    _ChannelIO_SDWebImageTransition *transition = [_ChannelIO_SDWebImageTransition new];
#if SD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlDown | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionCurlDown;
#endif
    transition.duration = duration;
    return transition;
}

@end

#endif
