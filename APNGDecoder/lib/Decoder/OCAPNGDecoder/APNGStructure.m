//
//  APNGStructure.m
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/1.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import "APNGStructure.h"
#import "NSData+decode.h"

@implementation APNGChunk

- (id)initWithLength:(UInt32)length type:(NSString *)type start:(NSUInteger )start end:(NSUInteger)end
{
    if (self = [super init])
    {
        self.length = length;
        self.type = type;
        self.start = start;
        self.end = end;
    }
    return self;
}

@end

@implementation APNGACTL

- (id)initWithFrames:(UInt32)frames plays:(UInt32)plays
{
    if (self = [super init])
    {
        self.numOfPlays = plays;
        self.numOfFrames = frames;
    }
    return self;
}

- (id)initWithData:(NSData *)data
{
    if (self = [super init])
    {
        self.numOfFrames = NSSwapBigIntToHost([data getUInt32From:0]);
        self.numOfPlays = NSSwapBigIntToHost([data getUInt32From:4]);
    }
    return self;
}

@end

@implementation APNGIHDR

- (id)initWithWidth:(UInt32)width height:(UInt32)height bitDepth:(UInt8)bitDepth colorType:(UInt8)colorType compressMethod:(UInt8)compressMethod filterMethod:(UInt8)filterMethod interlaceMethod:(UInt8)interlaceMethod
{
    if (self = [super init])
    {
        self.width = width;
        self.height = height;
        self.bitDepth = bitDepth;
        self.colorType = colorType;
        self.compressMethod = compressMethod;
        self.filterMethod = filterMethod;
        self.interlaceMethod = interlaceMethod;
    }
    return self;
}

- (id)initWithData:(NSData *)data
{
    if (self = [super init])
    {
        NSUInteger start = 0;
        self.width = NSSwapBigIntToHost([data getUInt32From:start]);
        self.height = NSSwapBigIntToHost([data getUInt32From:start + 4]);
        self.bitDepth =  [data getUInt8From:start + 8];
        self.colorType = [data getUInt8From:start + 9];
        self.compressMethod = [data getUInt8From:start + 10];
        self.filterMethod = [data getUInt8From:start + 11];
        self.interlaceMethod = [data getUInt8From:start + 12];
    }
    return self;
}

@end

@implementation APNGFCTL

- (id)initWithSeq:(UInt32)seq width:(UInt32)width height:(UInt32)height xOffset:(UInt32)xOffset yOffset:(UInt32)yOffset delayNum:(UInt16)delayNum delayDen:(UInt16)delayDen disposeOp:(UInt8)disposeOp blendOp:(UInt8)blendOp
{
    if (self = [super init])
    {
        self.sequence_number = seq;
        self.width = width;
        self.height = height;
        self.x_offset = xOffset;
        self.y_offset = yOffset;
        self.delay_num = delayNum;
        self.delay_den = delayDen;
        self.dispose_op = disposeOp;
        self.blend_op = blendOp;
    }
    return self;
}

- (id)initWithData:(NSData *)data
{
    if (self = [super init])
    {
        self.sequence_number = NSSwapBigIntToHost([data getUInt32From:0]);
        self.width = NSSwapBigIntToHost([data getUInt32From:4]);
        self.height = NSSwapBigIntToHost([data getUInt32From:8]);
        self.x_offset = NSSwapBigIntToHost([data getUInt32From:12]);
        self.y_offset = NSSwapBigIntToHost([data getUInt32From:16]);
        /**
         The `delay_num` and `delay_den` parameters together specify a fraction indicating the time to display the current frame, in seconds. If the denominator is 0, it is to be treated as if it were 100 (that is, `delay_num` then specifies 1/100ths of a second). If the the value of the numerator is 0 the decoder should render the next frame as quickly as possible, though viewers may impose a reasonable lower bound.
         */
        self.delay_num = NSSwapBigIntToHost([data getUInt16From:20]);
        self.delay_den = NSSwapBigIntToHost([data getUInt16From:22]);
        if (self.delay_den == 0)
        {
            self.delay_den = 100;
        }
        self.dispose_op = [data getUInt8From:24];
        self.blend_op = [data getUInt8From:25];
    }
    return self;
}

@end

@implementation APNGFrame

- (id)initWithFctl:(APNGFCTL *)fctl data:(NSArray<APNGChunk *> *)chunks
{
    if (self = [super init])
    {
        self.dataChunks = chunks;
        self.fctl = fctl;
    }
    return self;
}

@end

@implementation APNGAnimatedImage

- (id)initWithImage:(UIImage *)image duration:(double)duration
{
    if (self = [super init])
    {
        self.image = image;
        self.duration = duration;
    }
    return self;
}

@end
