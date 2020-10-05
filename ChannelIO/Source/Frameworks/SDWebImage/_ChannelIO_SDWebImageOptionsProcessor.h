/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "_ChannelIO_SDWebImageCompat.h"
#import "_ChannelIO_SDWebImageDefine.h"

@class _ChannelIO_SDWebImageOptionsResult;

typedef _ChannelIO_SDWebImageOptionsResult * _Nullable(^_ChannelIO_SDWebImageOptionsProcessorBlock)(NSURL * _Nullable url, _ChannelIO_SDWebImageOptions options, _ChannelIO_SDWebImageContext * _Nullable context);

/**
 The options result contains both options and context.
 */
@interface _ChannelIO_SDWebImageOptionsResult : NSObject

/**
 WebCache options.
 */
@property (nonatomic, assign, readonly) _ChannelIO_SDWebImageOptions options;

/**
 Context options.
 */
@property (nonatomic, copy, readonly, nullable) _ChannelIO_SDWebImageContext *context;

/**
 Create a new options result.

 @param options options
 @param context context
 @return The options result contains both options and context.
 */
- (nonnull instancetype)initWithOptions:(_ChannelIO_SDWebImageOptions)options context:(nullable _ChannelIO_SDWebImageContext *)context;

@end

/**
 This is the protocol for options processor.
 Options processor can be used, to control the final result for individual image request's `SDWebImageOptions` and `SDWebImageContext`
 Implements the protocol to have a global control for each indivadual image request's option.
 */
@protocol _ChannelIO_SDWebImageOptionsProcessor <NSObject>

/**
 Return the processed options result for specify image URL, with its options and context

 @param url The URL to the image
 @param options A mask to specify options to use for this request
 @param context A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 @return The processed result, contains both options and context
 */
- (nullable _ChannelIO_SDWebImageOptionsResult *)processedResultForURL:(nullable NSURL *)url
                                                    options:(_ChannelIO_SDWebImageOptions)options
                                                    context:(nullable _ChannelIO_SDWebImageContext *)context;

@end

/**
 A options processor class with block.
 */
@interface _ChannelIO_SDWebImageOptionsProcessor : NSObject<_ChannelIO_SDWebImageOptionsProcessor>

- (nonnull instancetype)initWithBlock:(nonnull _ChannelIO_SDWebImageOptionsProcessorBlock)block;
+ (nonnull instancetype)optionsProcessorWithBlock:(nonnull _ChannelIO_SDWebImageOptionsProcessorBlock)block;

@end
