/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_NSButton+WebCache.h"

#if SD_MAC

#import "objc/runtime.h"
#import "_ChannelIO_UIView+WebCacheOperation.h"
#import "_ChannelIO_UIView+WebCache.h"
#import "_ChannelIO_SDInternalMacros.h"

static NSString * const _ChannelIO_SDAlternateImageOperationKey = @"NSButtonAlternateImageOperation";

@implementation NSButton (_ChannelIO_WebCache)

#pragma mark - Image

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options context:(nullable SDWebImageContext *)context {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options progress:(nullable SDImageLoaderProgressBlock)progressBlock completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)_ChannelIO_sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                   context:(nullable SDWebImageContext *)context
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    self.sd_currentImageURL = url;
    [self sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:context
                       setImageBlock:nil
                            progress:progressBlock
                           completed:^(NSImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Alternate Image

- (void)_ChannelIO_sd_setAlternateImageWithURL:(nullable NSURL *)url {
    [self sd_setAlternateImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self sd_setAlternateImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options {
    [self sd_setAlternateImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options context:(nullable SDWebImageContext *)context {
    [self sd_setAlternateImageWithURL:url placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)_ChannelIO_sd_setAlternateImageWithURL:(nullable NSURL *)url completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setAlternateImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setAlternateImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setAlternateImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)_ChannelIO_sd_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options progress:(nullable SDImageLoaderProgressBlock)progressBlock completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self sd_setAlternateImageWithURL:url placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)_ChannelIO_sd_setAlternateImageWithURL:(nullable NSURL *)url
                   placeholderImage:(nullable UIImage *)placeholder
                            options:(SDWebImageOptions)options
                            context:(nullable SDWebImageContext *)context
                           progress:(nullable SDImageLoaderProgressBlock)progressBlock
                          completed:(nullable SDExternalCompletionBlock)completedBlock {
    self.sd_currentAlternateImageURL = url;
    
    SDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[SDWebImageContextSetImageOperationKey] = SDAlternateImageOperationKey;
    @weakify(self);
    [self sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:^(NSImage * _Nullable image, NSData * _Nullable imageData, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @strongify(self);
                           self.alternateImage = image;
                       }
                            progress:progressBlock
                           completed:^(NSImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Cancel

- (void)_ChannelIO_sd_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:NSStringFromClass([self class])];
}

- (void)_ChannelIO_sd_cancelCurrentAlternateImageLoad {
    [self sd_cancelImageLoadOperationWithKey:SDAlternateImageOperationKey];
}

#pragma mar - Private

- (NSURL *)sd_currentImageURL {
    return objc_getAssociatedObject(self, @selector(sd_currentImageURL));
}

- (void)setSd_currentImageURL:(NSURL *)sd_currentImageURL {
    objc_setAssociatedObject(self, @selector(sd_currentImageURL), sd_currentImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)sd_currentAlternateImageURL {
    return objc_getAssociatedObject(self, @selector(sd_currentAlternateImageURL));
}

- (void)setSd_currentAlternateImageURL:(NSURL *)sd_currentAlternateImageURL {
    objc_setAssociatedObject(self, @selector(sd_currentAlternateImageURL), sd_currentAlternateImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#endif
