//
//  NSData+decode.h
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/1.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (decode)

- (UInt32)getUInt32From:(NSUInteger)start;

- (UInt16)getUInt16From:(NSUInteger)start;

- (UInt8)getUInt8From:(NSUInteger)start;

- (NSString *)getStringFrom:(NSUInteger)start to:(NSUInteger)end encoding:(NSStringEncoding)encoding;


@end

NS_ASSUME_NONNULL_END
