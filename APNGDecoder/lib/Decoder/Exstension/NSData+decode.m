//
//  NSData+decode.m
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/1.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import "NSData+decode.h"

@implementation NSData (decode)

- (UInt32)getUInt32From:(NSUInteger)start
{
    NSAssert(start + 4 <= self.length, @"start index must be no more than total length - 4");
    Byte *bytes = (Byte *)malloc(4 * sizeof(Byte));
    [self getBytes:bytes range:NSMakeRange(start, 4)];
    UInt32 ret = * ((UInt32 *)bytes);
    free(bytes);
    return ret;
}

- (UInt16)getUInt16From:(NSUInteger)start
{
    NSAssert(start + 2 <= self.length, @"start index must be no more than total length - 2");
    Byte *bytes = (Byte *)malloc(2 * sizeof(Byte));
    [self getBytes:bytes range:NSMakeRange(start, 2)];
    UInt16 ret = * ((UInt16 *)bytes);
    free(bytes);
    return ret;
}

- (UInt8)getUInt8From:(NSUInteger)start
{
    NSAssert(start + 1 <= self.length, @"start index must be no more than total length - 1");
    Byte *bytes = (Byte *)malloc(1 * sizeof(Byte));
    [self getBytes:bytes range:NSMakeRange(start, 1)];
    UInt8 ret = * ((UInt8 *)bytes);
    free(bytes);
    return ret;
}

- (NSString *)getStringFrom:(NSUInteger)start to:(NSUInteger)end encoding:(NSStringEncoding)encoding
{
    NSAssert(start >= 0 && end >= 0 && end >= start, @"start and end must be reasonable");
    NSUInteger length = end - start;
    NSAssert(self.length >= length, @"length overflowed");
    NSData *subData = [self subdataWithRange:NSMakeRange(start, length)];
    NSString *string = [[NSString alloc] initWithData:subData encoding:encoding];
    return string;
}

@end
