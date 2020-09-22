/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageCompat.h"

@class _ChannelIO_SDAsyncBlockOperation;
typedef void (^_ChannelIO_SDAsyncBlock)(_ChannelIO_SDAsyncBlockOperation * __nonnull asyncOperation);

/// A async block operation, success after you call `completer` (not like `NSBlockOperation` which is for sync block, success on return)
@interface _ChannelIO_SDAsyncBlockOperation : NSOperation

- (nonnull instancetype)initWithBlock:(nonnull _ChannelIO_SDAsyncBlock)block;
+ (nonnull instancetype)blockOperationWithBlock:(nonnull _ChannelIO_SDAsyncBlock)block;
- (void)complete;

@end
