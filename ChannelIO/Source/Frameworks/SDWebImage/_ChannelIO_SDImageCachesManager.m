/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDImageCachesManager.h"
#import "_ChannelIO_SDImageCachesManagerOperation.h"
#import "_ChannelIO_SDImageCache.h"
#import "_ChannelIO_SDInternalMacros.h"

@interface _ChannelIO_SDImageCachesManager ()

@property (nonatomic, strong, nonnull) dispatch_semaphore_t cachesLock;

@end

@implementation _ChannelIO_SDImageCachesManager
{
    NSMutableArray<id<_ChannelIO_SDImageCache>> *_imageCaches;
}

+ (_ChannelIO_SDImageCachesManager *)sharedManager {
    static dispatch_once_t onceToken;
    static _ChannelIO_SDImageCachesManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[_ChannelIO_SDImageCachesManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queryOperationPolicy = SDImageCachesManagerOperationPolicySerial;
        self.storeOperationPolicy = SDImageCachesManagerOperationPolicyHighestOnly;
        self.removeOperationPolicy = SDImageCachesManagerOperationPolicyConcurrent;
        self.containsOperationPolicy = SDImageCachesManagerOperationPolicySerial;
        self.clearOperationPolicy = SDImageCachesManagerOperationPolicyConcurrent;
        // initialize with default image caches
        _imageCaches = [NSMutableArray arrayWithObject:[_ChannelIO_SDImageCache sharedImageCache]];
        _cachesLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSArray<id<_ChannelIO_SDImageCache>> *)caches {
    SD_LOCK(self.cachesLock);
    NSArray<id<_ChannelIO_SDImageCache>> *caches = [_imageCaches copy];
    SD_UNLOCK(self.cachesLock);
    return caches;
}

- (void)setCaches:(NSArray<id<_ChannelIO_SDImageCache>> *)caches {
    SD_LOCK(self.cachesLock);
    [_imageCaches removeAllObjects];
    if (caches.count) {
        [_imageCaches addObjectsFromArray:caches];
    }
    SD_UNLOCK(self.cachesLock);
}

#pragma mark - Cache IO operations

- (void)addCache:(id<_ChannelIO_SDImageCache>)cache {
    if (![cache conformsToProtocol:@protocol(_ChannelIO_SDImageCache)]) {
        return;
    }
    SD_LOCK(self.cachesLock);
    [_imageCaches addObject:cache];
    SD_UNLOCK(self.cachesLock);
}

- (void)removeCache:(id<_ChannelIO_SDImageCache>)cache {
    if (![cache conformsToProtocol:@protocol(_ChannelIO_SDImageCache)]) {
        return;
    }
    SD_LOCK(self.cachesLock);
    [_imageCaches removeObject:cache];
    SD_UNLOCK(self.cachesLock);
}

#pragma mark - SDImageCache

- (id<_ChannelIO_SDWebImageOperation>)queryImageForKey:(NSString *)key options:(_ChannelIO_SDWebImageOptions)options context:(_ChannelIO_SDWebImageContext *)context completion:(_ChannelIO_SDImageCacheQueryCompletionBlock)completionBlock {
    return [self queryImageForKey:key options:options context:context cacheType:SDImageCacheTypeAll completion:completionBlock];
}

- (id<_ChannelIO_SDWebImageOperation>)queryImageForKey:(NSString *)key options:(_ChannelIO_SDWebImageOptions)options context:(_ChannelIO_SDWebImageContext *)context cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDImageCacheQueryCompletionBlock)completionBlock {
    if (!key) {
        return nil;
    }
    NSArray<id<_ChannelIO_SDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return nil;
    } else if (count == 1) {
        return [caches.firstObject queryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock];
    }
    switch (self.queryOperationPolicy) {
        case SDImageCachesManagerOperationPolicyHighestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.lastObject;
            return [cache queryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyLowestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.firstObject;
            return [cache queryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyConcurrent: {
            _ChannelIO_SDImageCachesManagerOperation *operation = [_ChannelIO_SDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentQueryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        case SDImageCachesManagerOperationPolicySerial: {
            _ChannelIO_SDImageCachesManagerOperation *operation = [_ChannelIO_SDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self serialQueryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        default:
            return nil;
            break;
    }
}

- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDWebImageNoParamsBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<_ChannelIO_SDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.storeOperationPolicy) {
        case SDImageCachesManagerOperationPolicyHighestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.lastObject;
            [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyLowestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.firstObject;
            [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyConcurrent: {
            _ChannelIO_SDImageCachesManagerOperation *operation = [_ChannelIO_SDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case SDImageCachesManagerOperationPolicySerial: {
            [self serialStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

- (void)removeImageForKey:(NSString *)key cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDWebImageNoParamsBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<_ChannelIO_SDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject removeImageForKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.removeOperationPolicy) {
        case SDImageCachesManagerOperationPolicyHighestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.lastObject;
            [cache removeImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyLowestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.firstObject;
            [cache removeImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyConcurrent: {
            _ChannelIO_SDImageCachesManagerOperation *operation = [_ChannelIO_SDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case SDImageCachesManagerOperationPolicySerial: {
            [self serialRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

- (void)containsImageForKey:(NSString *)key cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDImageCacheContainsCompletionBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<_ChannelIO_SDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject containsImageForKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.clearOperationPolicy) {
        case SDImageCachesManagerOperationPolicyHighestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.lastObject;
            [cache containsImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyLowestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.firstObject;
            [cache containsImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyConcurrent: {
            _ChannelIO_SDImageCachesManagerOperation *operation = [_ChannelIO_SDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case SDImageCachesManagerOperationPolicySerial: {
            _ChannelIO_SDImageCachesManagerOperation *operation = [_ChannelIO_SDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self serialContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        default:
            break;
    }
}

- (void)clearWithCacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDWebImageNoParamsBlock)completionBlock {
    NSArray<id<_ChannelIO_SDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject clearWithCacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.clearOperationPolicy) {
        case SDImageCachesManagerOperationPolicyHighestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.lastObject;
            [cache clearWithCacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyLowestOnly: {
            id<_ChannelIO_SDImageCache> cache = caches.firstObject;
            [cache clearWithCacheType:cacheType completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyConcurrent: {
            _ChannelIO_SDImageCachesManagerOperation *operation = [_ChannelIO_SDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentClearWithCacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case SDImageCachesManagerOperationPolicySerial: {
            [self serialClearWithCacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Concurrent Operation

- (void)concurrentQueryImageForKey:(NSString *)key options:(_ChannelIO_SDWebImageOptions)options context:(_ChannelIO_SDWebImageContext *)context cacheType:(_ChannelIO_SDImageCacheType)queryCacheType completion:(_ChannelIO_SDImageCacheQueryCompletionBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator operation:(_ChannelIO_SDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<_ChannelIO_SDImageCache> cache in enumerator) {
        [cache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable image, NSData * _Nullable data, _ChannelIO_SDImageCacheType cacheType) {
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (image) {
                // Success
                [operation done];
                if (completionBlock) {
                    completionBlock(image, data, cacheType);
                }
                return;
            }
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock(nil, nil, SDImageCacheTypeNone);
                }
            }
        }];
    }
}

- (void)concurrentStoreImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator operation:(_ChannelIO_SDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<_ChannelIO_SDImageCache> cache in enumerator) {
        [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

- (void)concurrentRemoveImageForKey:(NSString *)key cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator operation:(_ChannelIO_SDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<_ChannelIO_SDImageCache> cache in enumerator) {
        [cache removeImageForKey:key cacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

- (void)concurrentContainsImageForKey:(NSString *)key cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDImageCacheContainsCompletionBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator operation:(_ChannelIO_SDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<_ChannelIO_SDImageCache> cache in enumerator) {
        [cache containsImageForKey:key cacheType:cacheType completion:^(_ChannelIO_SDImageCacheType containsCacheType) {
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (containsCacheType != SDImageCacheTypeNone) {
                // Success
                [operation done];
                if (completionBlock) {
                    completionBlock(containsCacheType);
                }
                return;
            }
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock(SDImageCacheTypeNone);
                }
            }
        }];
    }
}

- (void)concurrentClearWithCacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator operation:(_ChannelIO_SDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<_ChannelIO_SDImageCache> cache in enumerator) {
        [cache clearWithCacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

#pragma mark - Serial Operation

- (void)serialQueryImageForKey:(NSString *)key options:(_ChannelIO_SDWebImageOptions)options context:(_ChannelIO_SDWebImageContext *)context cacheType:(_ChannelIO_SDImageCacheType)queryCacheType completion:(_ChannelIO_SDImageCacheQueryCompletionBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator operation:(_ChannelIO_SDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    id<_ChannelIO_SDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        [operation done];
        if (completionBlock) {
            completionBlock(nil, nil, SDImageCacheTypeNone);
        }
        return;
    }
    @weakify(self);
    [cache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable image, NSData * _Nullable data, _ChannelIO_SDImageCacheType cacheType) {
        @strongify(self);
        if (operation.isCancelled) {
            // Cancelled
            return;
        }
        if (operation.isFinished) {
            // Finished
            return;
        }
        [operation completeOne];
        if (image) {
            // Success
            [operation done];
            if (completionBlock) {
                completionBlock(image, data, cacheType);
            }
            return;
        }
        // Next
        [self serialQueryImageForKey:key options:options context:context cacheType:queryCacheType completion:completionBlock enumerator:enumerator operation:operation];
    }];
}

- (void)serialStoreImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<_ChannelIO_SDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @weakify(self);
    [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:^{
        @strongify(self);
        // Next
        [self serialStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

- (void)serialRemoveImageForKey:(NSString *)key cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<_ChannelIO_SDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @weakify(self);
    [cache removeImageForKey:key cacheType:cacheType completion:^{
        @strongify(self);
        // Next
        [self serialRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

- (void)serialContainsImageForKey:(NSString *)key cacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDImageCacheContainsCompletionBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator operation:(_ChannelIO_SDImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    id<_ChannelIO_SDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        [operation done];
        if (completionBlock) {
            completionBlock(SDImageCacheTypeNone);
        }
        return;
    }
    @weakify(self);
    [cache containsImageForKey:key cacheType:cacheType completion:^(_ChannelIO_SDImageCacheType containsCacheType) {
        @strongify(self);
        if (operation.isCancelled) {
            // Cancelled
            return;
        }
        if (operation.isFinished) {
            // Finished
            return;
        }
        [operation completeOne];
        if (containsCacheType != SDImageCacheTypeNone) {
            // Success
            [operation done];
            if (completionBlock) {
                completionBlock(containsCacheType);
            }
            return;
        }
        // Next
        [self serialContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator operation:operation];
    }];
}

- (void)serialClearWithCacheType:(_ChannelIO_SDImageCacheType)cacheType completion:(_ChannelIO_SDWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<_ChannelIO_SDImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<_ChannelIO_SDImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @weakify(self);
    [cache clearWithCacheType:cacheType completion:^{
        @strongify(self);
        // Next
        [self serialClearWithCacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

@end
