//
//  JGProgressHUDShadow.m
//  JGProgressHUD
//
//  Created by Jonas Gessner on 25.09.17.
//  Copyright © 2017 Jonas Gessner. All rights reserved.
//

#import "_ChannelIO_JGProgressHUDShadow.h"

@implementation _ChannelIO_JGProgressHUDShadow

+ (instancetype)shadowWithColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius opacity:(float)opacity {
    return [[self alloc] initWithColor:color offset:offset radius:radius opacity:opacity];
}

- (instancetype)initWithColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius opacity:(float)opacity {
    self = [super init];
    
    if (self) {
        _color = color;
        _offset = offset;
        _radius = radius;
        _opacity = opacity;
    }
    
    return self;
}

@end
