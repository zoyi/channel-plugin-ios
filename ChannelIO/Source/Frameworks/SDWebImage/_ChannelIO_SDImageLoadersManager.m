/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDImageLoadersManager.h"
#import "_ChannelIO_SDWebImageDownloader.h"
#import "_ChannelIO_SDInternalMacros.h"

@interface _ChannelIO_SDImageLoadersManager ()

@property (nonatomic, strong, nonnull) dispatch_semaphore_t loadersLock;

@end

@implementation _ChannelIO_SDImageLoadersManager
{
    NSMutableArray<id<_ChannelIO_SDImageLoader>>* _imageLoaders;
}

+ (_ChannelIO_SDImageLoadersManager *)sharedManager {
    static dispatch_once_t onceToken;
    static _ChannelIO_SDImageLoadersManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[_ChannelIO_SDImageLoadersManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // initialize with default image loaders
        _imageLoaders = [NSMutableArray arrayWithObject:[_ChannelIO_SDWebImageDownloader sharedDownloader]];
        _loadersLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSArray<id<_ChannelIO_SDImageLoader>> *)loaders {
    SD_LOCK(self.loadersLock);
    NSArray<id<_ChannelIO_SDImageLoader>>* loaders = [_imageLoaders copy];
    SD_UNLOCK(self.loadersLock);
    return loaders;
}

- (void)setLoaders:(NSArray<id<_ChannelIO_SDImageLoader>> *)loaders {
    SD_LOCK(self.loadersLock);
    [_imageLoaders removeAllObjects];
    if (loaders.count) {
        [_imageLoaders addObjectsFromArray:loaders];
    }
    SD_UNLOCK(self.loadersLock);
}

#pragma mark - Loader Property

- (void)addLoader:(id<_ChannelIO_SDImageLoader>)loader {
    if (![loader conformsToProtocol:@protocol(_ChannelIO_SDImageLoader)]) {
        return;
    }
    SD_LOCK(self.loadersLock);
    [_imageLoaders addObject:loader];
    SD_UNLOCK(self.loadersLock);
}

- (void)removeLoader:(id<_ChannelIO_SDImageLoader>)loader {
    if (![loader conformsToProtocol:@protocol(_ChannelIO_SDImageLoader)]) {
        return;
    }
    SD_LOCK(self.loadersLock);
    [_imageLoaders removeObject:loader];
    SD_UNLOCK(self.loadersLock);
}

#pragma mark - SDImageLoader

- (BOOL)canRequestImageForURL:(nullable NSURL *)url {
    NSArray<id<_ChannelIO_SDImageLoader>> *loaders = self.loaders;
    for (id<_ChannelIO_SDImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return YES;
        }
    }
    return NO;
}

- (id<_ChannelIO_SDWebImageOperation>)requestImageWithURL:(NSURL *)url options:(_ChannelIO_SDWebImageOptions)options context:(_ChannelIO_SDWebImageContext *)context progress:(_ChannelIO_SDImageLoaderProgressBlock)progressBlock completed:(_ChannelIO_SDImageLoaderCompletedBlock)completedBlock {
    if (!url) {
        return nil;
    }
    NSArray<id<_ChannelIO_SDImageLoader>> *loaders = self.loaders;
    for (id<_ChannelIO_SDImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return [loader requestImageWithURL:url options:options context:context progress:progressBlock completed:completedBlock];
        }
    }
    return nil;
}

- (BOOL)shouldBlockFailedURLWithURL:(NSURL *)url error:(NSError *)error {
    NSArray<id<_ChannelIO_SDImageLoader>> *loaders = self.loaders;
    for (id<_ChannelIO_SDImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return [loader shouldBlockFailedURLWithURL:url error:error];
        }
    }
    return NO;
}

@end
