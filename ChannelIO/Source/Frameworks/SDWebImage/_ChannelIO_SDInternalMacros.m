/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "_ChannelIO_SDInternalMacros.h"

void _ChannelIO_sd_executeCleanupBlock (__strong _ChannelIO_sd_cleanupBlock_t *block) {
    (*block)();
}
