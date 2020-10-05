/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageManager.h"
#import "_ChannelIO_SDImageCache.h"
#import "_ChannelIO_SDWebImageDownloader.h"
#import "_ChannelIO_UIImage+Metadata.h"
#import "_ChannelIO_SDAssociatedObject.h"
#import "_ChannelIO_SDWebImageError.h"
#import "_ChannelIO_SDInternalMacros.h"

static id<_ChannelIO_SDImageCache> _defaultImageCache;
static id<_ChannelIO_SDImageLoader> _defaultImageLoader;

@interface _ChannelIO_SDWebImageCombinedOperation ()

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (strong, nonatomic, readwrite, nullable) id<_ChannelIO_SDWebImageOperation> loaderOperation;
@property (strong, nonatomic, readwrite, nullable) id<_ChannelIO_SDWebImageOperation> cacheOperation;
@property (weak, nonatomic, nullable) _ChannelIO_SDWebImageManager *manager;

@end

@interface _ChannelIO_SDWebImageManager ()

@property (strong, nonatomic, readwrite, nonnull) _ChannelIO_SDImageCache *imageCache;
@property (strong, nonatomic, readwrite, nonnull) id<_ChannelIO_SDImageLoader> imageLoader;
@property (strong, nonatomic, nonnull) NSMutableSet<NSURL *> *failedURLs;
@property (strong, nonatomic, nonnull) dispatch_semaphore_t failedURLsLock; // a lock to keep the access to `failedURLs` thread-safe
@property (strong, nonatomic, nonnull) NSMutableSet<_ChannelIO_SDWebImageCombinedOperation *> *runningOperations;
@property (strong, nonatomic, nonnull) dispatch_semaphore_t runningOperationsLock; // a lock to keep the access to `runningOperations` thread-safe

@end

@implementation _ChannelIO_SDWebImageManager

+ (id<_ChannelIO_SDImageCache>)defaultImageCache {
    return _defaultImageCache;
}

+ (void)setDefaultImageCache:(id<_ChannelIO_SDImageCache>)defaultImageCache {
    if (defaultImageCache && ![defaultImageCache conformsToProtocol:@protocol(_ChannelIO_SDImageCache)]) {
        return;
    }
    _defaultImageCache = defaultImageCache;
}

+ (id<_ChannelIO_SDImageLoader>)defaultImageLoader {
    return _defaultImageLoader;
}

+ (void)setDefaultImageLoader:(id<_ChannelIO_SDImageLoader>)defaultImageLoader {
    if (defaultImageLoader && ![defaultImageLoader conformsToProtocol:@protocol(_ChannelIO_SDImageLoader)]) {
        return;
    }
    _defaultImageLoader = defaultImageLoader;
}

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    id<_ChannelIO_SDImageCache> cache = [[self class] defaultImageCache];
    if (!cache) {
        cache = [_ChannelIO_SDImageCache sharedImageCache];
    }
    id<_ChannelIO_SDImageLoader> loader = [[self class] defaultImageLoader];
    if (!loader) {
        loader = [_ChannelIO_SDWebImageDownloader sharedDownloader];
    }
    return [self initWithCache:cache loader:loader];
}

- (nonnull instancetype)initWithCache:(nonnull id<_ChannelIO_SDImageCache>)cache loader:(nonnull id<_ChannelIO_SDImageLoader>)loader {
    if ((self = [super init])) {
        _imageCache = cache;
        _imageLoader = loader;
        _failedURLs = [NSMutableSet new];
        _failedURLsLock = dispatch_semaphore_create(1);
        _runningOperations = [NSMutableSet new];
        _runningOperationsLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    if (!url) {
        return @"";
    }
    
    NSString *key;
    // Cache Key Filter
    id<_ChannelIO_SDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
    if (cacheKeyFilter) {
        key = [cacheKeyFilter cacheKeyForURL:url];
    } else {
        key = url.absoluteString;
    }
    
    return key;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url context:(nullable _ChannelIO_SDWebImageContext *)context {
    if (!url) {
        return @"";
    }
    
    NSString *key;
    // Cache Key Filter
    id<_ChannelIO_SDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
    if (context[_ChannelIO_SDWebImageContextCacheKeyFilter]) {
        cacheKeyFilter = context[_ChannelIO_SDWebImageContextCacheKeyFilter];
    }
    if (cacheKeyFilter) {
        key = [cacheKeyFilter cacheKeyForURL:url];
    } else {
        key = url.absoluteString;
    }
    
    // Thumbnail Key Appending
    NSValue *thumbnailSizeValue = context[_ChannelIO_SDWebImageContextImageThumbnailPixelSize];
    if (thumbnailSizeValue != nil) {
        CGSize thumbnailSize = CGSizeZero;
#if SD_MAC
        thumbnailSize = thumbnailSizeValue.sizeValue;
#else
        thumbnailSize = thumbnailSizeValue.CGSizeValue;
#endif
        BOOL preserveAspectRatio = YES;
        NSNumber *preserveAspectRatioValue = context[_ChannelIO_SDWebImageContextImagePreserveAspectRatio];
        if (preserveAspectRatioValue != nil) {
            preserveAspectRatio = preserveAspectRatioValue.boolValue;
        }
        key = _ChannelIO_SDThumbnailedKeyForKey(key, thumbnailSize, preserveAspectRatio);
    }
    
    // Transformer Key Appending
    id<_ChannelIO_SDImageTransformer> transformer = self.transformer;
    if (context[_ChannelIO_SDWebImageContextImageTransformer]) {
        transformer = context[_ChannelIO_SDWebImageContextImageTransformer];
        if (![transformer conformsToProtocol:@protocol(_ChannelIO_SDImageTransformer)]) {
            transformer = nil;
        }
    }
    if (transformer) {
        key = _ChannelIO_SDTransformedKeyForKey(key, transformer.transformerKey);
    }
    
    return key;
}

- (_ChannelIO_SDWebImageCombinedOperation *)loadImageWithURL:(NSURL *)url options:(_ChannelIO_SDWebImageOptions)options progress:(_ChannelIO_SDImageLoaderProgressBlock)progressBlock completed:(_ChannelIO_SDInternalCompletionBlock)completedBlock {
    return [self loadImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

- (_ChannelIO_SDWebImageCombinedOperation *)loadImageWithURL:(nullable NSURL *)url
                                          options:(_ChannelIO_SDWebImageOptions)options
                                          context:(nullable _ChannelIO_SDWebImageContext *)context
                                         progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                                        completed:(nonnull _ChannelIO_SDInternalCompletionBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, Xcode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    _ChannelIO_SDWebImageCombinedOperation *operation = [_ChannelIO_SDWebImageCombinedOperation new];
    operation.manager = self;

    BOOL isFailedUrl = NO;
    if (url) {
        SD_LOCK(self.failedURLsLock);
        isFailedUrl = [self.failedURLs containsObject:url];
        SD_UNLOCK(self.failedURLsLock);
    }

    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        NSString *description = isFailedUrl ? @"Image url is blacklisted" : @"Image url is nil";
        NSInteger code = isFailedUrl ? SDWebImageErrorBlackListed : SDWebImageErrorInvalidURL;
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:_ChannelIO_SDWebImageErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : description}] url:url];
        return operation;
    }

    SD_LOCK(self.runningOperationsLock);
    [self.runningOperations addObject:operation];
    SD_UNLOCK(self.runningOperationsLock);
    
    // Preprocess the options and context arg to decide the final the result for manager
    _ChannelIO_SDWebImageOptionsResult *result = [self processedResultForURL:url options:options context:context];
    
    // Start the entry to load image from cache
    [self callCacheProcessForOperation:operation url:url options:result.options context:result.context progress:progressBlock completed:completedBlock];

    return operation;
}

- (void)cancelAll {
    SD_LOCK(self.runningOperationsLock);
    NSSet<_ChannelIO_SDWebImageCombinedOperation *> *copiedOperations = [self.runningOperations copy];
    SD_UNLOCK(self.runningOperationsLock);
    [copiedOperations makeObjectsPerformSelector:@selector(cancel)]; // This will call `safelyRemoveOperationFromRunning:` and remove from the array
}

- (BOOL)isRunning {
    BOOL isRunning = NO;
    SD_LOCK(self.runningOperationsLock);
    isRunning = (self.runningOperations.count > 0);
    SD_UNLOCK(self.runningOperationsLock);
    return isRunning;
}

- (void)removeFailedURL:(NSURL *)url {
    if (!url) {
        return;
    }
    SD_LOCK(self.failedURLsLock);
    [self.failedURLs removeObject:url];
    SD_UNLOCK(self.failedURLsLock);
}

- (void)removeAllFailedURLs {
    SD_LOCK(self.failedURLsLock);
    [self.failedURLs removeAllObjects];
    SD_UNLOCK(self.failedURLsLock);
}

#pragma mark - Private

// Query normal cache process
- (void)callCacheProcessForOperation:(nonnull _ChannelIO_SDWebImageCombinedOperation *)operation
                                 url:(nonnull NSURL *)url
                             options:(_ChannelIO_SDWebImageOptions)options
                             context:(nullable _ChannelIO_SDWebImageContext *)context
                            progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                           completed:(nullable _ChannelIO_SDInternalCompletionBlock)completedBlock {
    // Grab the image cache to use
    id<_ChannelIO_SDImageCache> imageCache;
    if ([context[_ChannelIO_SDWebImageContextImageCache] conformsToProtocol:@protocol(_ChannelIO_SDImageCache)]) {
        imageCache = context[_ChannelIO_SDWebImageContextImageCache];
    } else {
        imageCache = self.imageCache;
    }
    
    // Get the query cache type
    _ChannelIO_SDImageCacheType queryCacheType = SDImageCacheTypeAll;
    if (context[_ChannelIO_SDWebImageContextQueryCacheType]) {
        queryCacheType = [context[_ChannelIO_SDWebImageContextQueryCacheType] integerValue];
    }
    
    // Check whether we should query cache
    BOOL shouldQueryCache = !SD_OPTIONS_CONTAINS(options, SDWebImageFromLoaderOnly);
    if (shouldQueryCache) {
        NSString *key = [self cacheKeyForURL:url context:context];
        @weakify(operation);
        operation.cacheOperation = [imageCache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, _ChannelIO_SDImageCacheType cacheType) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:_ChannelIO_SDWebImageErrorDomain code:SDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during querying the cache"}] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            } else if (context[_ChannelIO_SDWebImageContextImageTransformer] && !cachedImage) {
                // Have a chance to query original cache instead of downloading
                [self callOriginalCacheProcessForOperation:operation url:url options:options context:context progress:progressBlock completed:completedBlock];
                return;
            }
            
            // Continue download process
            [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:cachedImage cachedData:cachedData cacheType:cacheType progress:progressBlock completed:completedBlock];
        }];
    } else {
        // Continue download process
        [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:nil cachedData:nil cacheType:SDImageCacheTypeNone progress:progressBlock completed:completedBlock];
    }
}

// Query original cache process
- (void)callOriginalCacheProcessForOperation:(nonnull _ChannelIO_SDWebImageCombinedOperation *)operation
                                         url:(nonnull NSURL *)url
                                     options:(_ChannelIO_SDWebImageOptions)options
                                     context:(nullable _ChannelIO_SDWebImageContext *)context
                                    progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                                   completed:(nullable _ChannelIO_SDInternalCompletionBlock)completedBlock {
    // Grab the image cache to use
    id<_ChannelIO_SDImageCache> imageCache;
    if ([context[_ChannelIO_SDWebImageContextImageCache] conformsToProtocol:@protocol(_ChannelIO_SDImageCache)]) {
        imageCache = context[_ChannelIO_SDWebImageContextImageCache];
    } else {
        imageCache = self.imageCache;
    }
    
    // Get the original query cache type
    _ChannelIO_SDImageCacheType originalQueryCacheType = SDImageCacheTypeNone;
    if (context[_ChannelIO_SDWebImageContextOriginalQueryCacheType]) {
        originalQueryCacheType = [context[_ChannelIO_SDWebImageContextOriginalQueryCacheType] integerValue];
    }
    
    // Check whether we should query original cache
    BOOL shouldQueryOriginalCache = (originalQueryCacheType != SDImageCacheTypeNone);
    if (shouldQueryOriginalCache) {
        // Change originContext to mutable
        _ChannelIO_SDWebImageMutableContext * __block originContext;
        if (context) {
            originContext = [context mutableCopy];
        } else {
            originContext = [NSMutableDictionary dictionary];
        }
        
        // Disable transformer for cache key generation
        id<_ChannelIO_SDImageTransformer> transformer = originContext[_ChannelIO_SDWebImageContextImageTransformer];
        originContext[_ChannelIO_SDWebImageContextImageTransformer] = [NSNull null];
        
        NSString *key = [self cacheKeyForURL:url context:originContext];
        @weakify(operation);
        operation.cacheOperation = [imageCache queryImageForKey:key options:options context:context cacheType:originalQueryCacheType completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, _ChannelIO_SDImageCacheType cacheType) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:_ChannelIO_SDWebImageErrorDomain code:SDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during querying the cache"}] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            }
            
            // Add original transformer
            if (transformer) {
                originContext[_ChannelIO_SDWebImageContextImageTransformer] = transformer;
            }
            
            // Use the store cache process instead of downloading, and ignore .refreshCached option for now
            [self callStoreCacheProcessForOperation:operation url:url options:options context:context downloadedImage:cachedImage downloadedData:cachedData finished:YES progress:progressBlock completed:completedBlock];
            
            [self safelyRemoveOperationFromRunning:operation];
        }];
    } else {
        // Continue download process
        [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:nil cachedData:nil cacheType:originalQueryCacheType progress:progressBlock completed:completedBlock];
    }
}

// Download process
- (void)callDownloadProcessForOperation:(nonnull _ChannelIO_SDWebImageCombinedOperation *)operation
                                    url:(nonnull NSURL *)url
                                options:(_ChannelIO_SDWebImageOptions)options
                                context:(_ChannelIO_SDWebImageContext *)context
                            cachedImage:(nullable UIImage *)cachedImage
                             cachedData:(nullable NSData *)cachedData
                              cacheType:(_ChannelIO_SDImageCacheType)cacheType
                               progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                              completed:(nullable _ChannelIO_SDInternalCompletionBlock)completedBlock {
    // Grab the image loader to use
    id<_ChannelIO_SDImageLoader> imageLoader;
    if ([context[_ChannelIO_SDWebImageContextImageLoader] conformsToProtocol:@protocol(_ChannelIO_SDImageLoader)]) {
        imageLoader = context[_ChannelIO_SDWebImageContextImageLoader];
    } else {
        imageLoader = self.imageLoader;
    }
    
    // Check whether we should download image from network
    BOOL shouldDownload = !SD_OPTIONS_CONTAINS(options, SDWebImageFromCacheOnly);
    shouldDownload &= (!cachedImage || options & SDWebImageRefreshCached);
    shouldDownload &= (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url]);
    shouldDownload &= [imageLoader canRequestImageForURL:url];
    if (shouldDownload) {
        if (cachedImage && options & SDWebImageRefreshCached) {
            // If image was found in the cache but SDWebImageRefreshCached is provided, notify about the cached image
            // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
            [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            // Pass the cached image to the image loader. The image loader should check whether the remote image is equal to the cached image.
            _ChannelIO_SDWebImageMutableContext *mutableContext;
            if (context) {
                mutableContext = [context mutableCopy];
            } else {
                mutableContext = [NSMutableDictionary dictionary];
            }
            mutableContext[_ChannelIO_SDWebImageContextLoaderCachedImage] = cachedImage;
            context = [mutableContext copy];
        }
        
        @weakify(operation);
        operation.loaderOperation = [imageLoader requestImageWithURL:url options:options context:context progress:progressBlock completed:^(UIImage *downloadedImage, NSData *downloadedData, NSError *error, BOOL finished) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:_ChannelIO_SDWebImageErrorDomain code:SDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during sending the request"}] url:url];
            } else if (cachedImage && options & SDWebImageRefreshCached && [error.domain isEqualToString:_ChannelIO_SDWebImageErrorDomain] && error.code == SDWebImageErrorCacheNotModified) {
                // Image refresh hit the NSURLCache cache, do not call the completion block
            } else if ([error.domain isEqualToString:_ChannelIO_SDWebImageErrorDomain] && error.code == SDWebImageErrorCancelled) {
                // Download operation cancelled by user before sending the request, don't block failed URL
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error url:url];
            } else if (error) {
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error url:url];
                BOOL shouldBlockFailedURL = [self shouldBlockFailedURLWithURL:url error:error options:options context:context];
                
                if (shouldBlockFailedURL) {
                    SD_LOCK(self.failedURLsLock);
                    [self.failedURLs addObject:url];
                    SD_UNLOCK(self.failedURLsLock);
                }
            } else {
                if ((options & SDWebImageRetryFailed)) {
                    SD_LOCK(self.failedURLsLock);
                    [self.failedURLs removeObject:url];
                    SD_UNLOCK(self.failedURLsLock);
                }
                // Continue store cache process
                [self callStoreCacheProcessForOperation:operation url:url options:options context:context downloadedImage:downloadedImage downloadedData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
            }
            
            if (finished) {
                [self safelyRemoveOperationFromRunning:operation];
            }
        }];
    } else if (cachedImage) {
        [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
        [self safelyRemoveOperationFromRunning:operation];
    } else {
        // Image not in cache and download disallowed by delegate
        [self callCompletionBlockForOperation:operation completion:completedBlock image:nil data:nil error:nil cacheType:SDImageCacheTypeNone finished:YES url:url];
        [self safelyRemoveOperationFromRunning:operation];
    }
}

// Store cache process
- (void)callStoreCacheProcessForOperation:(nonnull _ChannelIO_SDWebImageCombinedOperation *)operation
                                      url:(nonnull NSURL *)url
                                  options:(_ChannelIO_SDWebImageOptions)options
                                  context:(_ChannelIO_SDWebImageContext *)context
                          downloadedImage:(nullable UIImage *)downloadedImage
                           downloadedData:(nullable NSData *)downloadedData
                                 finished:(BOOL)finished
                                 progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                                completed:(nullable _ChannelIO_SDInternalCompletionBlock)completedBlock {
    // the target image store cache type
    _ChannelIO_SDImageCacheType storeCacheType = SDImageCacheTypeAll;
    if (context[_ChannelIO_SDWebImageContextStoreCacheType]) {
        storeCacheType = [context[_ChannelIO_SDWebImageContextStoreCacheType] integerValue];
    }
    // the original store image cache type
    _ChannelIO_SDImageCacheType originalStoreCacheType = SDImageCacheTypeNone;
    if (context[_ChannelIO_SDWebImageContextOriginalStoreCacheType]) {
        originalStoreCacheType = [context[_ChannelIO_SDWebImageContextOriginalStoreCacheType] integerValue];
    }
    // origin cache key
    _ChannelIO_SDWebImageMutableContext *originContext = [context mutableCopy];
    // disable transformer for cache key generation
    originContext[_ChannelIO_SDWebImageContextImageTransformer] = [NSNull null];
    NSString *key = [self cacheKeyForURL:url context:originContext];
    id<_ChannelIO_SDImageTransformer> transformer = context[_ChannelIO_SDWebImageContextImageTransformer];
    if (![transformer conformsToProtocol:@protocol(_ChannelIO_SDImageTransformer)]) {
        transformer = nil;
    }
    id<_ChannelIO_SDWebImageCacheSerializer> cacheSerializer = context[_ChannelIO_SDWebImageContextCacheSerializer];
    
    BOOL shouldTransformImage = downloadedImage && transformer;
    shouldTransformImage = shouldTransformImage && (!downloadedImage._ChannelIO_sd_isAnimated || (options & SDWebImageTransformAnimatedImage));
    shouldTransformImage = shouldTransformImage && (!downloadedImage._ChannelIO_sd_isVector || (options & SDWebImageTransformVectorImage));
    BOOL shouldCacheOriginal = downloadedImage && finished;
    
    // if available, store original image to cache
    if (shouldCacheOriginal) {
        // normally use the store cache type, but if target image is transformed, use original store cache type instead
        _ChannelIO_SDImageCacheType targetStoreCacheType = shouldTransformImage ? originalStoreCacheType : storeCacheType;
        if (cacheSerializer && (targetStoreCacheType == SDImageCacheTypeDisk || targetStoreCacheType == SDImageCacheTypeAll)) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                @autoreleasepool {
                    NSData *cacheData = [cacheSerializer cacheDataWithImage:downloadedImage originalData:downloadedData imageURL:url];
                    [self storeImage:downloadedImage imageData:cacheData forKey:key cacheType:targetStoreCacheType options:options context:context completion:^{
                        // Continue transform process
                        [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
                    }];
                }
            });
        } else {
            [self storeImage:downloadedImage imageData:downloadedData forKey:key cacheType:targetStoreCacheType options:options context:context completion:^{
                // Continue transform process
                [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
            }];
        }
    } else {
        // Continue transform process
        [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
    }
}

// Transform process
- (void)callTransformProcessForOperation:(nonnull _ChannelIO_SDWebImageCombinedOperation *)operation
                                     url:(nonnull NSURL *)url
                                 options:(_ChannelIO_SDWebImageOptions)options
                                 context:(_ChannelIO_SDWebImageContext *)context
                           originalImage:(nullable UIImage *)originalImage
                            originalData:(nullable NSData *)originalData
                                finished:(BOOL)finished
                                progress:(nullable _ChannelIO_SDImageLoaderProgressBlock)progressBlock
                               completed:(nullable _ChannelIO_SDInternalCompletionBlock)completedBlock {
    // the target image store cache type
    _ChannelIO_SDImageCacheType storeCacheType = SDImageCacheTypeAll;
    if (context[_ChannelIO_SDWebImageContextStoreCacheType]) {
        storeCacheType = [context[_ChannelIO_SDWebImageContextStoreCacheType] integerValue];
    }
    // transformed cache key
    NSString *key = [self cacheKeyForURL:url context:context];
    id<_ChannelIO_SDImageTransformer> transformer = context[_ChannelIO_SDWebImageContextImageTransformer];
    if (![transformer conformsToProtocol:@protocol(_ChannelIO_SDImageTransformer)]) {
        transformer = nil;
    }
    id<_ChannelIO_SDWebImageCacheSerializer> cacheSerializer = context[_ChannelIO_SDWebImageContextCacheSerializer];
    
    BOOL shouldTransformImage = originalImage && transformer;
    shouldTransformImage = shouldTransformImage && (!originalImage._ChannelIO_sd_isAnimated || (options & SDWebImageTransformAnimatedImage));
    shouldTransformImage = shouldTransformImage && (!originalImage._ChannelIO_sd_isVector || (options & SDWebImageTransformVectorImage));
    // if available, store transformed image to cache
    if (shouldTransformImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            @autoreleasepool {
                UIImage *transformedImage = [transformer transformedImageWithImage:originalImage forKey:key];
                if (transformedImage && finished) {
                    BOOL imageWasTransformed = ![transformedImage isEqual:originalImage];
                    NSData *cacheData;
                    // pass nil if the image was transformed, so we can recalculate the data from the image
                    if (cacheSerializer && (storeCacheType == SDImageCacheTypeDisk || storeCacheType == SDImageCacheTypeAll)) {
                        cacheData = [cacheSerializer cacheDataWithImage:transformedImage originalData:(imageWasTransformed ? nil : originalData) imageURL:url];
                    } else {
                        cacheData = (imageWasTransformed ? nil : originalData);
                    }
                    [self storeImage:transformedImage imageData:cacheData forKey:key cacheType:storeCacheType options:options context:context completion:^{
                        [self callCompletionBlockForOperation:operation completion:completedBlock image:transformedImage data:originalData error:nil cacheType:SDImageCacheTypeNone finished:finished url:url];
                    }];
                } else {
                    [self callCompletionBlockForOperation:operation completion:completedBlock image:transformedImage data:originalData error:nil cacheType:SDImageCacheTypeNone finished:finished url:url];
                }
            }
        });
    } else {
        [self callCompletionBlockForOperation:operation completion:completedBlock image:originalImage data:originalData error:nil cacheType:SDImageCacheTypeNone finished:finished url:url];
    }
}

#pragma mark - Helper

- (void)safelyRemoveOperationFromRunning:(nullable _ChannelIO_SDWebImageCombinedOperation*)operation {
    if (!operation) {
        return;
    }
    SD_LOCK(self.runningOperationsLock);
    [self.runningOperations removeObject:operation];
    SD_UNLOCK(self.runningOperationsLock);
}

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)data
            forKey:(nullable NSString *)key
         cacheType:(_ChannelIO_SDImageCacheType)cacheType
           options:(_ChannelIO_SDWebImageOptions)options
           context:(nullable _ChannelIO_SDWebImageContext *)context
        completion:(nullable _ChannelIO_SDWebImageNoParamsBlock)completion {
    id<_ChannelIO_SDImageCache> imageCache;
    if ([context[_ChannelIO_SDWebImageContextImageCache] conformsToProtocol:@protocol(_ChannelIO_SDImageCache)]) {
        imageCache = context[_ChannelIO_SDWebImageContextImageCache];
    } else {
        imageCache = self.imageCache;
    }
    BOOL waitStoreCache = SD_OPTIONS_CONTAINS(options, SDWebImageWaitStoreCache);
    // Check whether we should wait the store cache finished. If not, callback immediately
    [imageCache storeImage:image imageData:data forKey:key cacheType:cacheType completion:^{
        if (waitStoreCache) {
            if (completion) {
                completion();
            }
        }
    }];
    if (!waitStoreCache) {
        if (completion) {
            completion();
        }
    }
}

- (void)callCompletionBlockForOperation:(nullable _ChannelIO_SDWebImageCombinedOperation*)operation
                             completion:(nullable _ChannelIO_SDInternalCompletionBlock)completionBlock
                                  error:(nullable NSError *)error
                                    url:(nullable NSURL *)url {
    [self callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:SDImageCacheTypeNone finished:YES url:url];
}

- (void)callCompletionBlockForOperation:(nullable _ChannelIO_SDWebImageCombinedOperation*)operation
                             completion:(nullable _ChannelIO_SDInternalCompletionBlock)completionBlock
                                  image:(nullable UIImage *)image
                                   data:(nullable NSData *)data
                                  error:(nullable NSError *)error
                              cacheType:(_ChannelIO_SDImageCacheType)cacheType
                               finished:(BOOL)finished
                                    url:(nullable NSURL *)url {
    dispatch_main_async_safe(^{
        if (completionBlock) {
            completionBlock(image, data, error, cacheType, finished, url);
        }
    });
}

- (BOOL)shouldBlockFailedURLWithURL:(nonnull NSURL *)url
                              error:(nonnull NSError *)error
                            options:(_ChannelIO_SDWebImageOptions)options
                            context:(nullable _ChannelIO_SDWebImageContext *)context {
    id<_ChannelIO_SDImageLoader> imageLoader;
    if ([context[_ChannelIO_SDWebImageContextImageLoader] conformsToProtocol:@protocol(_ChannelIO_SDImageLoader)]) {
        imageLoader = context[_ChannelIO_SDWebImageContextImageLoader];
    } else {
        imageLoader = self.imageLoader;
    }
    // Check whether we should block failed url
    BOOL shouldBlockFailedURL;
    if ([self.delegate respondsToSelector:@selector(imageManager:shouldBlockFailedURL:withError:)]) {
        shouldBlockFailedURL = [self.delegate imageManager:self shouldBlockFailedURL:url withError:error];
    } else {
        shouldBlockFailedURL = [imageLoader shouldBlockFailedURLWithURL:url error:error];
    }
    
    return shouldBlockFailedURL;
}

- (_ChannelIO_SDWebImageOptionsResult *)processedResultForURL:(NSURL *)url options:(_ChannelIO_SDWebImageOptions)options context:(_ChannelIO_SDWebImageContext *)context {
    _ChannelIO_SDWebImageOptionsResult *result;
    _ChannelIO_SDWebImageMutableContext *mutableContext = [_ChannelIO_SDWebImageMutableContext dictionary];
    
    // Image Transformer from manager
    if (!context[_ChannelIO_SDWebImageContextImageTransformer]) {
        id<_ChannelIO_SDImageTransformer> transformer = self.transformer;
        [mutableContext setValue:transformer forKey:_ChannelIO_SDWebImageContextImageTransformer];
    }
    // Cache key filter from manager
    if (!context[_ChannelIO_SDWebImageContextCacheKeyFilter]) {
        id<_ChannelIO_SDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
        [mutableContext setValue:cacheKeyFilter forKey:_ChannelIO_SDWebImageContextCacheKeyFilter];
    }
    // Cache serializer from manager
    if (!context[_ChannelIO_SDWebImageContextCacheSerializer]) {
        id<_ChannelIO_SDWebImageCacheSerializer> cacheSerializer = self.cacheSerializer;
        [mutableContext setValue:cacheSerializer forKey:_ChannelIO_SDWebImageContextCacheSerializer];
    }
    
    if (mutableContext.count > 0) {
        if (context) {
            [mutableContext addEntriesFromDictionary:context];
        }
        context = [mutableContext copy];
    }
    
    // Apply options processor
    if (self.optionsProcessor) {
        result = [self.optionsProcessor processedResultForURL:url options:options context:context];
    }
    if (!result) {
        // Use default options result
        result = [[_ChannelIO_SDWebImageOptionsResult alloc] initWithOptions:options context:context];
    }
    
    return result;
}

@end


@implementation _ChannelIO_SDWebImageCombinedOperation

- (void)cancel {
    @synchronized(self) {
        if (self.isCancelled) {
            return;
        }
        self.cancelled = YES;
        if (self.cacheOperation) {
            [self.cacheOperation cancel];
            self.cacheOperation = nil;
        }
        if (self.loaderOperation) {
            [self.loaderOperation cancel];
            self.loaderOperation = nil;
        }
        [self.manager safelyRemoveOperationFromRunning:self];
    }
}

@end
