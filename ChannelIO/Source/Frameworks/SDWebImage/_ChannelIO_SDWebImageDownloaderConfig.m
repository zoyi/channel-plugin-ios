/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDWebImageDownloaderConfig.h"

static _ChannelIO_SDWebImageDownloaderConfig * _ChannelIO__defaultDownloaderConfig;

@implementation _ChannelIO_SDWebImageDownloaderConfig

+ (_ChannelIO_SDWebImageDownloaderConfig *)defaultDownloaderConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ChannelIO__defaultDownloaderConfig = [_ChannelIO_SDWebImageDownloaderConfig new];
    });
    return _ChannelIO__defaultDownloaderConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxConcurrentDownloads = 6;
        _downloadTimeout = 15.0;
        _executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    _ChannelIO_SDWebImageDownloaderConfig *config = [[[self class] allocWithZone:zone] init];
    config.maxConcurrentDownloads = self.maxConcurrentDownloads;
    config.downloadTimeout = self.downloadTimeout;
    config.minimumProgressInterval = self.minimumProgressInterval;
    config.sessionConfiguration = [self.sessionConfiguration copyWithZone:zone];
    config.operationClass = self.operationClass;
    config.executionOrder = self.executionOrder;
    config.urlCredential = self.urlCredential;
    config.username = self.username;
    config.password = self.password;
    
    return config;
}


@end
