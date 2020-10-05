/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "_ChannelIO_SDWebImageDownloaderDecryptor.h"

@interface _ChannelIO_SDWebImageDownloaderDecryptor ()

@property (nonatomic, copy, nonnull) _ChannelIO_SDWebImageDownloaderDecryptorBlock block;

@end

@implementation _ChannelIO_SDWebImageDownloaderDecryptor

- (instancetype)initWithBlock:(_ChannelIO_SDWebImageDownloaderDecryptorBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)decryptorWithBlock:(_ChannelIO_SDWebImageDownloaderDecryptorBlock)block {
    _ChannelIO_SDWebImageDownloaderDecryptor *decryptor = [[_ChannelIO_SDWebImageDownloaderDecryptor alloc] initWithBlock:block];
    return decryptor;
}

- (nullable NSData *)decryptedDataWithData:(nonnull NSData *)data response:(nullable NSURLResponse *)response {
    if (!self.block) {
        return nil;
    }
    return self.block(data, response);
}

@end

@implementation _ChannelIO_SDWebImageDownloaderDecryptor (Conveniences)

+ (_ChannelIO_SDWebImageDownloaderDecryptor *)base64Decryptor {
    static _ChannelIO_SDWebImageDownloaderDecryptor *decryptor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decryptor = [_ChannelIO_SDWebImageDownloaderDecryptor decryptorWithBlock:^NSData * _Nullable(NSData * _Nonnull data, NSURLResponse * _Nullable response) {
            NSData *modifiedData = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
            return modifiedData;
        }];
    });
    return decryptor;
}

@end
