/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "_ChannelIO_UIView+WebCacheOperation.h"
#import "_ChannelIO_UIView+WebCache.h"

@implementation UIImageView (_ChannelIO_WebCache)

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url {
    [self _ChannelIO_sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self _ChannelIO_sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options {
    [self _ChannelIO_sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options context:(nullable _ChannelIO_SDWebImageContext *)context {
    [self _ChannelIO_sd_setImageWithURL:url placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(_ChannelIO_SDWebImageOptions)options progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_setImageWithURL:url placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(_ChannelIO_SDWebImageOptions)options
                   context:(nullable _ChannelIO_SDWebImageContext *)context
                  progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable _ChannelIO_SDExternalCompletionBlock)completedBlock {
    [self _ChannelIO_sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:context
                       setImageBlock:nil
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, _ChannelIO_SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

@end
