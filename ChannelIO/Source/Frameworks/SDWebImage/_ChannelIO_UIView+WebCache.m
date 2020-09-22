/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIView+WebCache.h"
#import "objc/runtime.h"
#import "_ChannelIO_UIView+WebCacheOperation.h"
#import "_ChannelIO_SDWebImageError.h"
#import "_ChannelIO_SDInternalMacros.h"
#import "_ChannelIO_SDWebImageTransitionInternal.h"

const int64_t _ChannelIO_SDWebImageProgressUnitCountUnknown = 1LL;

@implementation UIView (_ChannelIO_WebCache)

- (nullable NSURL *)_ChannelIO_sd_imageURL {
    return objc_getAssociatedObject(self, @selector(_ChannelIO_sd_imageURL));
}

- (void)set_ChannelIO_sd_imageURL:(NSURL * _Nullable)sd_imageURL {
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_imageURL), sd_imageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSString *)_ChannelIO_sd_latestOperationKey {
    return objc_getAssociatedObject(self, @selector(_ChannelIO_sd_latestOperationKey));
}

- (void)set_ChannelIO_sd_latestOperationKey:(NSString * _Nullable)sd_latestOperationKey {
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_latestOperationKey), sd_latestOperationKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSProgress *)_ChannelIO_sd_imageProgress {
    NSProgress *progress = objc_getAssociatedObject(self, @selector(_ChannelIO_sd_imageProgress));
    if (!progress) {
        progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self._ChannelIO_sd_imageProgress = progress;
    }
    return progress;
}

- (void)set_ChannelIO_sd_imageProgress:(NSProgress *)sd_imageProgress {
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_imageProgress), sd_imageProgress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)_ChannelIO_sd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(_ChannelIO_SDWebImageOptions)options
                           context:(nullable _ChannelIO_SDWebImageContext *)context
                     setImageBlock:(nullable _ChannelIO_SDSetImageBlock)setImageBlock
                          progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                         completed:(nullable _ChannelIO_SDInternalCompletionBlock)completedBlock {
    if (context) {
        // copy to avoid mutable object
        context = [context copy];
    } else {
        context = [NSDictionary dictionary];
    }
    NSString *validOperationKey = context[_ChannelIO_SDWebImageContextSetImageOperationKey];
    if (!validOperationKey) {
        // pass through the operation key to downstream, which can used for tracing operation or image view class
        validOperationKey = NSStringFromClass([self class]);
        _ChannelIO_SDWebImageMutableContext *mutableContext = [context mutableCopy];
        mutableContext[_ChannelIO_SDWebImageContextSetImageOperationKey] = validOperationKey;
        context = [mutableContext copy];
    }
    self._ChannelIO_sd_latestOperationKey = validOperationKey;
    [self _ChannelIO_sd_cancelImageLoadOperationWithKey:validOperationKey];
    self._ChannelIO_sd_imageURL = url;
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
          [self _ChannelIO_sd_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:SDImageCacheTypeNone imageURL:url];
        });
    }
    
    if (url) {
        // reset the progress
        NSProgress *imageProgress = objc_getAssociatedObject(self, @selector(_ChannelIO_sd_imageProgress));
        if (imageProgress) {
            imageProgress.totalUnitCount = 0;
            imageProgress.completedUnitCount = 0;
        }
        
#if SD_UIKIT || SD_MAC
        // check and start image indicator
        [self _ChannelIO_sd_startImageIndicator];
        id<_ChannelIO_SDWebImageIndicator> imageIndicator = self._ChannelIO_sd_imageIndicator;
#endif
        _ChannelIO_SDWebImageManager *manager = context[_ChannelIO_SDWebImageContextCustomManager];
        if (!manager) {
            manager = [_ChannelIO_SDWebImageManager sharedManager];
        } else {
            // remove this manager to avoid retain cycle (manger -> loader -> operation -> context -> manager)
            _ChannelIO_SDWebImageMutableContext *mutableContext = [context mutableCopy];
            mutableContext[_ChannelIO_SDWebImageContextCustomManager] = nil;
            context = [mutableContext copy];
        }
        
        _ChannelIO_SDImageLoaderProgressBlock combinedProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (imageProgress) {
                imageProgress.totalUnitCount = expectedSize;
                imageProgress.completedUnitCount = receivedSize;
            }
#if SD_UIKIT || SD_MAC
            if ([imageIndicator respondsToSelector:@selector(updateIndicatorProgress:)]) {
                double progress = 0;
                if (expectedSize != 0) {
                    progress = (double)receivedSize / expectedSize;
                }
                progress = MAX(MIN(progress, 1), 0); // 0.0 - 1.0
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageIndicator updateIndicatorProgress:progress];
                });
            }
#endif
            if (progressBlock) {
                progressBlock(receivedSize, expectedSize, targetURL);
            }
        };
        @weakify(self);
        id <_ChannelIO_SDWebImageOperation> operation = [manager loadImageWithURL:url options:options context:context progress:combinedProgressBlock completed:^(UIImage *image, NSData *data, NSError *error, _ChannelIO_SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            @strongify(self);
            if (!self) { return; }
            // if the progress not been updated, mark it to complete state
            if (imageProgress && finished && !error && imageProgress.totalUnitCount == 0 && imageProgress.completedUnitCount == 0) {
                imageProgress.totalUnitCount = _ChannelIO_SDWebImageProgressUnitCountUnknown;
                imageProgress.completedUnitCount = _ChannelIO_SDWebImageProgressUnitCountUnknown;
            }
            
#if SD_UIKIT || SD_MAC
            // check and stop image indicator
            if (finished) {
                [self _ChannelIO_sd_stopImageIndicator];
            }
#endif
            
            BOOL shouldCallCompletedBlock = finished || (options & SDWebImageAvoidAutoSetImage);
            BOOL shouldNotSetImage = ((image && (options & SDWebImageAvoidAutoSetImage)) ||
                                      (!image && !(options & SDWebImageDelayPlaceholder)));
            _ChannelIO_SDWebImageNoParamsBlock callCompletedBlockClojure = ^{
                if (!self) { return; }
                if (!shouldNotSetImage) {
                    [self _ChannelIO_sd_setNeedsLayout];
                }
                if (completedBlock && shouldCallCompletedBlock) {
                    completedBlock(image, data, error, cacheType, finished, url);
                }
            };
            
            // case 1a: we got an image, but the SDWebImageAvoidAutoSetImage flag is set
            // OR
            // case 1b: we got no image and the SDWebImageDelayPlaceholder is not set
            if (shouldNotSetImage) {
                dispatch_main_async_safe(callCompletedBlockClojure);
                return;
            }
            
            UIImage *targetImage = nil;
            NSData *targetData = nil;
            if (image) {
                // case 2a: we got an image and the SDWebImageAvoidAutoSetImage is not set
                targetImage = image;
                targetData = data;
            } else if (options & SDWebImageDelayPlaceholder) {
                // case 2b: we got no image and the SDWebImageDelayPlaceholder flag is set
                targetImage = placeholder;
                targetData = nil;
            }
            
#if SD_UIKIT || SD_MAC
            // check whether we should use the image transition
            _ChannelIO_SDWebImageTransition *transition = nil;
            BOOL shouldUseTransition = NO;
            if (options & SDWebImageForceTransition) {
                // Always
                shouldUseTransition = YES;
            } else if (cacheType == SDImageCacheTypeNone) {
                // From network
                shouldUseTransition = YES;
            } else {
                // From disk (and, user don't use sync query)
                if (cacheType == SDImageCacheTypeMemory) {
                    shouldUseTransition = NO;
                } else if (cacheType == SDImageCacheTypeDisk) {
                    if (options & SDWebImageQueryMemoryDataSync || options & SDWebImageQueryDiskDataSync) {
                        shouldUseTransition = NO;
                    } else {
                        shouldUseTransition = YES;
                    }
                } else {
                    // Not valid cache type, fallback
                    shouldUseTransition = NO;
                }
            }
            if (finished && shouldUseTransition) {
                transition = self._ChannelIO_sd_imageTransition;
            }
#endif
            dispatch_main_async_safe(^{
#if SD_UIKIT || SD_MAC
                [self _ChannelIO_sd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:transition cacheType:cacheType imageURL:imageURL];
#else
                [self sd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:cacheType imageURL:imageURL];
#endif
                callCompletedBlockClojure();
            });
        }];
        [self _ChannelIO_sd_setImageLoadOperation:operation forKey:validOperationKey];
    } else {
#if SD_UIKIT || SD_MAC
        [self _ChannelIO_sd_stopImageIndicator];
#endif
        dispatch_main_async_safe(^{
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:_ChannelIO_SDWebImageErrorDomain code:SDWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}];
                completedBlock(nil, nil, error, SDImageCacheTypeNone, YES, url);
            }
        });
    }
}

- (void)_ChannelIO_sd_cancelCurrentImageLoad {
    [self _ChannelIO_sd_cancelImageLoadOperationWithKey:self._ChannelIO_sd_latestOperationKey];
    self._ChannelIO_sd_latestOperationKey = nil;
}

- (void)_ChannelIO_sd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(_ChannelIO_SDSetImageBlock)setImageBlock cacheType:(_ChannelIO_SDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
#if SD_UIKIT || SD_MAC
    [self _ChannelIO_sd_setImage:image imageData:imageData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:nil cacheType:cacheType imageURL:imageURL];
#else
    // watchOS does not support view transition. Simplify the logic
    if (setImageBlock) {
        setImageBlock(image, imageData, cacheType, imageURL);
    } else if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        [imageView setImage:image];
    }
#endif
}

#if SD_UIKIT || SD_MAC
- (void)_ChannelIO_sd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(_ChannelIO_SDSetImageBlock)setImageBlock transition:(_ChannelIO_SDWebImageTransition *)transition cacheType:(_ChannelIO_SDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
    UIView *view = self;
    _ChannelIO_SDSetImageBlock finalSetImageBlock;
    if (setImageBlock) {
        finalSetImageBlock = setImageBlock;
    } else if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, _ChannelIO_SDImageCacheType setCacheType, NSURL *setImageURL) {
            imageView.image = setImage;
        };
    }
#if SD_UIKIT
    else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, _ChannelIO_SDImageCacheType setCacheType, NSURL *setImageURL) {
            [button setImage:setImage forState:UIControlStateNormal];
        };
    }
#endif
#if SD_MAC
    else if ([view isKindOfClass:[NSButton class]]) {
        NSButton *button = (NSButton *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, _ChannelIO_SDImageCacheType setCacheType, NSURL *setImageURL) {
            button.image = setImage;
        };
    }
#endif
    
    if (transition) {
#if SD_UIKIT
        [UIView transitionWithView:view duration:0 options:0 animations:^{
            if (!view._ChannelIO_sd_latestOperationKey) {
                return;
            }
            // 0 duration to let UIKit render placeholder and prepares block
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        } completion:^(BOOL finished) {
            [UIView transitionWithView:view duration:transition.duration options:transition.animationOptions animations:^{
                if (!view._ChannelIO_sd_latestOperationKey) {
                    return;
                }
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData, cacheType, imageURL);
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            } completion:^(BOOL finished) {
                if (!view._ChannelIO_sd_latestOperationKey) {
                    return;
                }
                if (transition.completion) {
                    transition.completion(finished);
                }
            }];
        }];
#elif SD_MAC
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull prepareContext) {
            if (!view.sd_latestOperationKey) {
                return;
            }
            // 0 duration to let AppKit render placeholder and prepares block
            prepareContext.duration = 0;
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        } completionHandler:^{
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                if (!view.sd_latestOperationKey) {
                    return;
                }
                context.duration = transition.duration;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                CAMediaTimingFunction *timingFunction = transition.timingFunction;
#pragma clang diagnostic pop
                if (!timingFunction) {
                    timingFunction = SDTimingFunctionFromAnimationOptions(transition.animationOptions);
                }
                context.timingFunction = timingFunction;
                context.allowsImplicitAnimation = SD_OPTIONS_CONTAINS(transition.animationOptions, SDWebImageAnimationOptionAllowsImplicitAnimation);
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData, cacheType, imageURL);
                }
                CATransition *trans = SDTransitionFromAnimationOptions(transition.animationOptions);
                if (trans) {
                    [view.layer addAnimation:trans forKey:kCATransition];
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            } completionHandler:^{
                if (!view.sd_latestOperationKey) {
                    return;
                }
                if (transition.completion) {
                    transition.completion(YES);
                }
            }];
        }];
#endif
    } else {
        if (finalSetImageBlock) {
            finalSetImageBlock(image, imageData, cacheType, imageURL);
        }
    }
}
#endif

- (void)_ChannelIO_sd_setNeedsLayout {
#if SD_UIKIT
    [self setNeedsLayout];
#elif SD_MAC
    [self setNeedsLayout:YES];
#elif SD_WATCH
    // Do nothing because WatchKit automatically layout the view after property change
#endif
}

#if SD_UIKIT || SD_MAC

#pragma mark - Image Transition
- (_ChannelIO_SDWebImageTransition *)_ChannelIO_sd_imageTransition {
    return objc_getAssociatedObject(self, @selector(_ChannelIO_sd_imageTransition));
}

- (void)set_ChannelIO_sd_imageTransition:(_ChannelIO_SDWebImageTransition *)sd_imageTransition {
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_imageTransition), sd_imageTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Indicator
- (id<_ChannelIO_SDWebImageIndicator>)_ChannelIO_sd_imageIndicator {
    return objc_getAssociatedObject(self, @selector(_ChannelIO_sd_imageIndicator));
}

- (void)set_ChannelIO_sd_imageIndicator:(id<_ChannelIO_SDWebImageIndicator>)sd_imageIndicator {
    // Remove the old indicator view
    id<_ChannelIO_SDWebImageIndicator> previousIndicator = self._ChannelIO_sd_imageIndicator;
    [previousIndicator.indicatorView removeFromSuperview];
    
    objc_setAssociatedObject(self, @selector(_ChannelIO_sd_imageIndicator), sd_imageIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Add the new indicator view
    UIView *view = sd_imageIndicator.indicatorView;
    if (CGRectEqualToRect(view.frame, CGRectZero)) {
        view.frame = self.bounds;
    }
    // Center the indicator view
#if SD_MAC
    [view setFrameOrigin:CGPointMake(round((NSWidth(self.bounds) - NSWidth(view.frame)) / 2), round((NSHeight(self.bounds) - NSHeight(view.frame)) / 2))];
#else
    view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
#endif
    view.hidden = NO;
    [self addSubview:view];
}

- (void)_ChannelIO_sd_startImageIndicator {
    id<_ChannelIO_SDWebImageIndicator> imageIndicator = self._ChannelIO_sd_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_safe(^{
        [imageIndicator startAnimatingIndicator];
    });
}

- (void)_ChannelIO_sd_stopImageIndicator {
    id<_ChannelIO_SDWebImageIndicator> imageIndicator = self._ChannelIO_sd_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_safe(^{
        [imageIndicator stopAnimatingIndicator];
    });
}

#endif

@end
