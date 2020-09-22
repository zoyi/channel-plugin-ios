//
//  JGProgressHUDPieIndicatorView.h
//  JGProgressHUD
//
//  Created by Jonas Gessner on 19.07.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "_ChannelIO_JGProgressHUD-Defines.h"
#import "_ChannelIO_JGProgressHUDIndicatorView.h"

/**
 A pie shaped determinate progress indicator.
 */
@interface _ChannelIO_JGProgressHUDPieIndicatorView : _ChannelIO_JGProgressHUDIndicatorView

/**
 Initializes the indicator view and sets the correct color to match the HUD style.
 */
- (instancetype __nonnull)initWithHUDStyle:(_ChannelIO_JGProgressHUDStyle)style __attribute((deprecated(("This initializer is no longer needed. Use the init initializer method."))));

/**
 Tint color of the Pie.
 @attention Custom values need to be set after assigning the indicator view to @c JGProgressHUD's @c indicatorView property.
 
 @b Default: White for JGProgressHUDStyleDark, otherwise black.
 */
@property (nonatomic, strong, nonnull) UIColor *color;

/**
 The background fill color inside the pie.
 @attention Custom values need to be set after assigning the indicator view to @c JGProgressHUD's @c indicatorView property.
 
 @b Default: Dark gray for JGProgressHUDStyleDark, otherwise light gray.
 */
@property (nonatomic, strong, nonnull) UIColor *fillColor;

@end
