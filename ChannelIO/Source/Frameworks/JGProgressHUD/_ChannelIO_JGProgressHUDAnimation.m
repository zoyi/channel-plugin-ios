//
//  JGProgressHUDAnimation.m
//  JGProgressHUD
//
//  Created by Jonas Gessner on 20.7.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//  

#import "_ChannelIO_JGProgressHUDAnimation.h"
#import "_ChannelIO_JGProgressHUD.h"

@interface _ChannelIO_JGProgressHUD (Private)

- (void)animationDidFinish:(BOOL)presenting;

@end

@interface _ChannelIO_JGProgressHUDAnimation () {
    BOOL _presenting;
}

@property (nonatomic, weak) _ChannelIO_JGProgressHUD *progressHUD;

@end

@implementation _ChannelIO_JGProgressHUDAnimation

#pragma mark - Initializers

+ (instancetype)animation {
    return [[self alloc] init];
}

#pragma mark - Public methods

- (void)show {
    _presenting = YES;
}

- (void)hide {
    _presenting = NO;
}

- (void)animationFinished {
    [self.progressHUD animationDidFinish:_presenting];
}

@end
