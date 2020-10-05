/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIButton+WebCache.h"

#if SD_UIKIT

#import "objc/runtime.h"
#import "_ChannelIO_UIView+WebCacheOperation.h"
#import "_ChannelIO_UIView+WebCache.h"
#import "_ChannelIO_SDInternalMacros.h"

static char _ChannelIO_imageURLStorageKey;

typedef NSMutableDictionary<NSString *, NSURL *> _ChannelIO_SDStateImageURLDictionary;

static inline NSString * _ChannelIO_imageURLKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"image_%lu", (unsigned long)state];
}

static inline NSString * _ChannelIO_backgroundImageURLKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"backgroundImage_%lu", (unsigned long)state];
}

static inline NSString * _ChannelIO_imageOperationKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"UIButtonImageOperation%lu", (unsigned long)state];
}

static inline NSString * _ChannelIO_backgroundImageOperationKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"UIButtonBackgroundImageOperation%lu", (unsigned long)state];
}

@implementation UIButton (_ChannelIO_WebCache)

#pragma mark - Image

- (nullable NSURL *)_ChannelIO_sd_currentImageURL {
    NSURL *url = self.sd_imageURLStorage[_ChannelIO_imageURLKeyForState(self.state)];

    if (!url) {
        url = self.sd_imageURLStorage[_ChannelIO_imageURLKeyForState(UIControlStateNormal)];
    }

    return url;
}

- (nullable NSURL *)_ChannelIO_sd_imageURLForState:(UIControlState)state {
    return self.sd_imageURLStorage[_ChannelIO_imageURLKeyForState(state)];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state {
    [self _ChannelIO_sd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self _ChannelIO_sd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options {
    [self _ChannelIO_sd_setImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options context:(nullable _ChannelIO_SDWebImageContext *)context {
    [self _ChannelIO_sd_setImageWithURL:url forState:state placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setImageWithURL:url forState:state placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url
                  forState:(UIControlState)state
          placeholderImage:(nullable UIImage *)placeholder
                   options:(_ChannelIO_SDWebImageOptions)options
                   context:(nullable _ChannelIO_SDWebImageContext *)context
                  progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.sd_imageURLStorage removeObjectForKey:_ChannelIO_imageURLKeyForState(state)];
    } else {
        self.sd_imageURLStorage[_ChannelIO_imageURLKeyForState(state)] = url;
    }
    
    _ChannelIO_SDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[_ChannelIO_SDWebImageContextSetImageOperationKey] = _ChannelIO_imageOperationKeyForState(state);
    @weakify(self);
    [self _ChannelIO_sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, _ChannelIO_SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @strongify(self);
                           [self setImage:image forState:state];
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, _ChannelIO_SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Background Image

- (nullable NSURL *)_ChannelIO_sd_currentBackgroundImageURL {
    NSURL *url = self.sd_imageURLStorage[_ChannelIO_backgroundImageURLKeyForState(self.state)];
    
    if (!url) {
        url = self.sd_imageURLStorage[_ChannelIO_backgroundImageURLKeyForState(UIControlStateNormal)];
    }
    
    return url;
}

- (nullable NSURL *)_ChannelIO_sd_backgroundImageURLForState:(UIControlState)state {
    return self.sd_imageURLStorage[_ChannelIO_backgroundImageURLKeyForState(state)];
}

- (void)_ChannelIO_sd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state {
    [self _ChannelIO_sd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)_ChannelIO_sd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self _ChannelIO_sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)_ChannelIO_sd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options {
    [self _ChannelIO_sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options context:(nullable _ChannelIO_SDWebImageContext *)context {
    [self _ChannelIO_sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)_ChannelIO_sd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)_ChannelIO_sd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)_ChannelIO_sd_setBackgroundImageWithURL:(nullable NSURL *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholder
                             options:(_ChannelIO_SDWebImageOptions)options
                             context:(nullable _ChannelIO_SDWebImageContext *)context
                            progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                           completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.sd_imageURLStorage removeObjectForKey:_ChannelIO_backgroundImageURLKeyForState(state)];
    } else {
        self.sd_imageURLStorage[_ChannelIO_backgroundImageURLKeyForState(state)] = url;
    }
    
    _ChannelIO_SDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[_ChannelIO_SDWebImageContextSetImageOperationKey] = _ChannelIO_backgroundImageOperationKeyForState(state);
    @weakify(self);
    [self _ChannelIO_sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, _ChannelIO_SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @strongify(self);
                           [self setBackgroundImage:image forState:state];
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, _ChannelIO_SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Cancel

- (void)_ChannelIO_sd_cancelImageLoadForState:(UIControlState)state {
    [self _ChannelIO_sd_cancelImageLoadOperationWithKey:_ChannelIO_imageOperationKeyForState(state)];
}

- (void)_ChannelIO_sd_cancelBackgroundImageLoadForState:(UIControlState)state {
    [self _ChannelIO_sd_cancelImageLoadOperationWithKey:_ChannelIO_backgroundImageOperationKeyForState(state)];
}

#pragma mark - Private

- (_ChannelIO_SDStateImageURLDictionary *)sd_imageURLStorage {
    _ChannelIO_SDStateImageURLDictionary *storage = objc_getAssociatedObject(self, &_ChannelIO_imageURLStorageKey);
    if (!storage) {
        storage = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &_ChannelIO_imageURLStorageKey, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return storage;
}

@end

#endif
