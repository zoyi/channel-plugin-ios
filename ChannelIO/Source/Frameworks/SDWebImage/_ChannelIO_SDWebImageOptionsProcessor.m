/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageOptionsProcessor.h"

@interface _ChannelIO_SDWebImageOptionsResult ()

@property (nonatomic, assign) _ChannelIO_SDWebImageOptions options;
@property (nonatomic, copy, nullable) _ChannelIO_SDWebImageContext *context;

@end

@implementation _ChannelIO_SDWebImageOptionsResult

- (instancetype)initWithOptions:(_ChannelIO_SDWebImageOptions)options context:(_ChannelIO_SDWebImageContext *)context {
    self = [super init];
    if (self) {
        self.options = options;
        self.context = context;
    }
    return self;
}

@end

@interface _ChannelIO_SDWebImageOptionsProcessor ()

@property (nonatomic, copy, nonnull) _ChannelIO_SDWebImageOptionsProcessorBlock block;

@end

@implementation _ChannelIO_SDWebImageOptionsProcessor

- (instancetype)initWithBlock:(_ChannelIO_SDWebImageOptionsProcessorBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)optionsProcessorWithBlock:(_ChannelIO_SDWebImageOptionsProcessorBlock)block {
    _ChannelIO_SDWebImageOptionsProcessor *optionsProcessor = [[_ChannelIO_SDWebImageOptionsProcessor alloc] initWithBlock:block];
    return optionsProcessor;
}

- (_ChannelIO_SDWebImageOptionsResult *)processedResultForURL:(NSURL *)url options:(_ChannelIO_SDWebImageOptions)options context:(_ChannelIO_SDWebImageContext *)context {
    if (!self.block) {
        return nil;
    }
    return self.block(url, options, context);
}

@end
