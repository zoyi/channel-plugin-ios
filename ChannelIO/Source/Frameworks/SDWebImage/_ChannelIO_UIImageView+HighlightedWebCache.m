/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIImageView+HighlightedWebCache.h"

#if SD_UIKIT

#import "_ChannelIO_UIView+WebCacheOperation.h"
#import "_ChannelIO_UIView+WebCache.h"
#import "_ChannelIO_SDInternalMacros.h"

static NSString * const _ChannelIO_SDHighlightedImageOperationKey = @"UIImageViewImageOperationHighlighted";

@implementation UIImageView (_ChannelIO_HighlightedWebCache)

- (void)_ChannelIO_sd_setHighlightedImageWithURL:(nullable NSURL *)url {
    [self _ChannelIO_sd_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setHighlightedImageWithURL:(nullable NSURL *)url options:(_ChannelIO_SDWebImageOptions)options {
    [self _ChannelIO_sd_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setHighlightedImageWithURL:(nullable NSURL *)url options:(_ChannelIO_SDWebImageOptions)options context:(nullable _ChannelIO_SDWebImageContext *)context {
    [self _ChannelIO_sd_setHighlightedImageWithURL:url options:options context:context progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setHighlightedImageWithURL:(nullable NSURL *)url completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setHighlightedImageWithURL:(nullable NSURL *)url options:(_ChannelIO_SDWebImageOptions)options completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setHighlightedImageWithURL:(NSURL *)url options:(_ChannelIO_SDWebImageOptions)options progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setHighlightedImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)_ChannelIO_sd_setHighlightedImageWithURL:(nullable NSURL *)url
                              options:(_ChannelIO_SDWebImageOptions)options
                              context:(nullable _ChannelIO_SDWebImageContext *)context
                             progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                            completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    @weakify(self);
    _ChannelIO_SDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[_ChannelIO_SDWebImageContextSetImageOperationKey] = _ChannelIO_SDHighlightedImageOperationKey;
    [self _ChannelIO_sd_internalSetImageWithURL:url
                    placeholderImage:nil
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, _ChannelIO_SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @strongify(self);
                           self.highlightedImage = image;
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, _ChannelIO_SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

@end

#endif
