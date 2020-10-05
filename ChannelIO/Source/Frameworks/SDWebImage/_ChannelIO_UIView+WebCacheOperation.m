/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_UIView+WebCacheOperation.h"
#import "objc/runtime.h"

static char _ChannelIO_loadOperationKey;

// key is strong, value is weak because operation instance is retained by SDWebImageManager's runningOperations property
// we should use lock to keep thread-safe because these method may not be accessed from main queue
typedef NSMapTable<NSString *, id<_ChannelIO_SDWebImageOperation>> _ChannelIO_SDOperationsDictionary;

@implementation UIView (_ChannelIO_WebCacheOperation)

- (_ChannelIO_SDOperationsDictionary *)_ChannelIO_sd_operationDictionary {
    @synchronized(self) {
        _ChannelIO_SDOperationsDictionary *operations = objc_getAssociatedObject(self, &_ChannelIO_loadOperationKey);
        if (operations) {
            return operations;
        }
        operations = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        objc_setAssociatedObject(self, &_ChannelIO_loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return operations;
    }
}

- (nullable id<_ChannelIO_SDWebImageOperation>)_ChannelIO_sd_imageLoadOperationForKey:(nullable NSString *)key  {
    id<_ChannelIO_SDWebImageOperation> operation;
    if (key) {
        _ChannelIO_SDOperationsDictionary *operationDictionary = [self _ChannelIO_sd_operationDictionary];
        @synchronized (self) {
            operation = [operationDictionary objectForKey:key];
        }
    }
    return operation;
}

- (void)_ChannelIO_sd_setImageLoadOperation:(nullable id<_ChannelIO_SDWebImageOperation>)operation forKey:(nullable NSString *)key {
    if (key) {
        [self _ChannelIO_sd_cancelImageLoadOperationWithKey:key];
        if (operation) {
            _ChannelIO_SDOperationsDictionary *operationDictionary = [self _ChannelIO_sd_operationDictionary];
            @synchronized (self) {
                [operationDictionary setObject:operation forKey:key];
            }
        }
    }
}

- (void)_ChannelIO_sd_cancelImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        // Cancel in progress downloader from queue
        _ChannelIO_SDOperationsDictionary *operationDictionary = [self _ChannelIO_sd_operationDictionary];
        id<_ChannelIO_SDWebImageOperation> operation;
        
        @synchronized (self) {
            operation = [operationDictionary objectForKey:key];
        }
        if (operation) {
            if ([operation conformsToProtocol:@protocol(_ChannelIO_SDWebImageOperation)]) {
                [operation cancel];
            }
            @synchronized (self) {
                [operationDictionary removeObjectForKey:key];
            }
        }
    }
}

- (void)_ChannelIO_sd_removeImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        _ChannelIO_SDOperationsDictionary *operationDictionary = [self _ChannelIO_sd_operationDictionary];
        @synchronized (self) {
            [operationDictionary removeObjectForKey:key];
        }
    }
}

@end
