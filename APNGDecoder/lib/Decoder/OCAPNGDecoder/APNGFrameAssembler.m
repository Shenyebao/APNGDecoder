//
//  APNGFrameAssembler.m
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/4.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import "APNGFrameAssembler.h"
#import "APNGStructure.h"
#import "zlib.h"
#import "zconf.h"

/**
 The first eight bytes of a PNG datastream always contain the following (decimal) values:
 0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A 0x00
 */
static const Byte pngSignatureBytes[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};

@interface APNGFrameAssembler()

@property (nonatomic, strong) NSMutableArray<APNGChunk *> *commonChunksBefore;
@property (nonatomic, strong) NSMutableArray<APNGChunk *> *commonChunksAfter;

@end

@implementation APNGFrameAssembler

+ (NSData *)pngSignature
{
    static dispatch_once_t token;
    static NSData *sigData = nil;;
    dispatch_once(&token, ^{
        sigData = [NSData dataWithBytes:pngSignatureBytes length:8];
    });
    return sigData;
}

- (id)init
{
    if (self = [super init])
    {
        self.commonChunksBefore = [NSMutableArray array];
        self.commonChunksAfter = [NSMutableArray array];
    }
    return self;
}

- (void)addChunkBefore:(APNGChunk *)chunk
{
    [self.commonChunksBefore addObject:chunk];
}

- (void)addChunkAfter:(APNGChunk *)chunk
{
    [self.commonChunksAfter addObject:chunk];
}

- (void)mergeCommonChunksWithFrame:(APNGFrame *)frame fromChunks:(NSArray<APNGChunk *> *)chunks fromRawData:(NSData *)rawdata toData:(NSMutableData *)data
{
    [chunks enumerateObjectsUsingBlock:^(APNGChunk * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.type isEqualToString:@"IHDR"])
        {
            //need to replace the width and height for each frame's IHDR
            NSMutableData *newIHDR = [NSMutableData data];
            //length and type
            [newIHDR appendData:[rawdata subdataWithRange:NSMakeRange(obj.start, 8)]];
            //get new width and height from each frame's fctl and replace the original value
            UInt32 width = NSSwapHostIntToBig(frame.fctl.width);
            UInt32 height = NSSwapHostIntToBig(frame.fctl.height);
            [newIHDR appendData: [NSData dataWithBytes:&width length:sizeof(width)]];
            [newIHDR appendData: [NSData dataWithBytes:&height length:sizeof(height)]];
            //copy the remaining bytes of the original IHDR except the crc part
            [newIHDR appendData: [rawdata subdataWithRange:NSMakeRange(obj.start + 8 + 8, 5)]];
            //crc value needs to be recalculated for each frame's IHDR, since their body has been changed
            UInt32 crcValue = NSSwapHostIntToBig([self getCrcOfData:newIHDR]);
            [newIHDR appendBytes:&crcValue length:4];
            [data appendData:newIHDR];
        }
        else
        {
            //other common chunks, simply add them sequentially
            [data appendData:[rawdata subdataWithRange:NSMakeRange(obj.start, obj.length)]];
        }
    }];
}

- (void)appendIDATWithFrame:(APNGFrame *)frame fromData:(NSData *)rawdata toData:(NSMutableData *)data
{
    NSUInteger start = frame.dataChunks.firstObject.start;
    NSUInteger end = frame.dataChunks.lastObject.end;
    NSData *fdatData = [rawdata subdataWithRange:NSMakeRange(start, end - start)];
    if ([frame.dataChunks.firstObject.type isEqualToString:@"IDAT"])
    {
        [data appendData:fdatData];
    }
    else
    {
        [frame.dataChunks enumerateObjectsUsingBlock:^(APNGChunk * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //idat has no sequence number (4bytes)
            UInt32 dataLength = obj.length - 12 - 4;
            UInt32 dataLengthBigSeq = NSSwapHostIntToBig(dataLength);
            NSMutableData *desData = [NSMutableData data];
            //append data length field
            [desData appendBytes:&dataLengthBigSeq length:sizeof(dataLengthBigSeq)];
            //append data type field
            const char type[] = "IDAT";
            [desData appendBytes:type length:4];
            //append data field
            [desData appendData:[rawdata subdataWithRange:NSMakeRange(obj.start + 12, dataLength)]];
            //calculate and append crc field
            UInt32 crcValue = NSSwapHostIntToBig([self getCrcOfData:desData]);
            [desData appendBytes:&crcValue length:4];
            [data appendData:desData];
        }];
    }
}

- (UInt32)getCrcOfData:(NSData *)data
{
    Byte *bytes = (Byte*)malloc(data.length);
    memcpy(bytes, data.bytes, data.length);
    //note that only the 'type' and 'data' fields will be calculated
    UInt32 crcValue = (UInt32)crc32(0, bytes + 4, (uInt) (data.length - 4));
    free(bytes);
    return crcValue;
}

- (NSData *)getPNGDataWithFrame:(APNGFrame *)frame data:(NSData *)data
{
    NSMutableData *pngData = [NSMutableData data];
    //append signature
    [pngData appendData:[[self class] pngSignature]];
    //append IHDR and common chunks before IDAT
    [self mergeCommonChunksWithFrame:frame fromChunks:_commonChunksBefore fromRawData:data toData:pngData];
    //append IDAT
    [self appendIDATWithFrame:frame fromData:data toData:pngData];
    //append common chunks after IDAT
    [self mergeCommonChunksWithFrame:frame fromChunks:_commonChunksAfter fromRawData:data toData:pngData];
    
    return pngData;
}

@end
