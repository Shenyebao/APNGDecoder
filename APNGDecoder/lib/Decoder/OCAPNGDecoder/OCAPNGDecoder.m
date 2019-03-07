//
//  OCAPNGDecoder.m
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/1.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import "OCAPNGDecoder.h"
#import "APNGDefine.h"
#import "APNGStructure.h"
#import "NSData+decode.h"
#import "APNGFrameAssembler.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@interface OCAPNGDecoder()
{
    CGContextRef _context;
}

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) APNGACTL *actl;
@property (nonatomic, strong) APNGIHDR *ihdr;
@property (nonatomic, strong) NSMutableArray<APNGChunk *> *chunks;
@property (nonatomic, strong) NSMutableArray<APNGFrame *> *frames;
@property (nonatomic, strong) APNGFrameAssembler *assembler;
//there might be more than one idat chunks. see http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html for details.
@property (nonatomic, strong) NSMutableArray<APNGAnimatedImage *> *animatedImages;

@end

@implementation OCAPNGDecoder

- (id)initWithData:( NSData * _Nonnull )data
{
    if (self = [super init])
    {
        self.data = data;
        self.chunks = [NSMutableArray array];
        self.frames = [NSMutableArray array];
        self.assembler = [[APNGFrameAssembler alloc] init];
    }
    return self;
}

- (void)startDecoding
{
    [self resolveChunks];
    self.animatedImages = [NSMutableArray arrayWithCapacity:[self numberOfFrames]];
    for (int i = 0; i < [self numberOfFrames]; i++)
    {
        APNGAnimatedImage *image = [self getImageOfIndex:i];
        [_animatedImages addObject:image];
    }
}

- (NSArray <APNGAnimatedImage *> *)images
{
    return [NSArray arrayWithArray:_animatedImages];
}

- (void)resolveChunks
{
    NSUInteger offset = 8;
    BOOL stop = NO;
    BOOL beforeIDAT = YES;
    while (!stop)
    {
        UInt32 dataLength = NSSwapBigIntToHost([_data getUInt32From:offset]);
        NSString *chunkType = [_data getStringFrom:offset + 4 to:offset + 8 encoding:NSASCIIStringEncoding];
        UInt32 chunkLength = 4 + dataLength + 4 + 4;
        APNGChunk *chunk = [[APNGChunk alloc] initWithLength:chunkLength type:chunkType start:offset end:offset + chunkLength];
        [self.chunks addObject:chunk];
        if ([chunk.type isEqualToString:@"IEND"])
        {
            stop = YES;
        }
        offset = offset + chunkLength;
        if ([chunk.type isEqualToString:@"IDAT"])
        {
            beforeIDAT = NO;
        }
        if ([chunk.type isEqualToString:@"acTL"])
        {
            self.actl = [self resolveACTLWithChunk:chunk];
        }
        if ([chunk.type isEqualToString:@"IHDR"])
        {
            self.ihdr = [self resolveIHDRWithChunk:chunk];
        }
        //common chunks, ihdr and iend
        if (![chunk.type isEqualToString:@"fcTL"] && ![chunk.type isEqualToString:@"fdAT"] && ![chunk.type isEqualToString:@"IDAT"] && ![chunk.type isEqualToString:@"acTL"])
        {
            if (beforeIDAT)
            {
                [_assembler addChunkBefore:chunk];
            }
            else
            {
                [_assembler addChunkAfter:chunk];
            }
        }
    }
    [_chunks enumerateObjectsUsingBlock:^(APNGChunk * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop){
        if ([obj.type isEqualToString:@"fcTL"])
        {
            NSMutableArray<APNGChunk *> *dataChunks = [NSMutableArray array];
            NSUInteger i = idx + 1;
            //Surprise! There could be multiple IDAT/fdAT chunks within a frame and you might never know that.
            while ([self.chunks[i].type isEqualToString:@"IDAT"] || [self.chunks[i].type isEqualToString:@"fdAT"]) {
                [dataChunks addObject:self.chunks[i]];
                i++;
            }
            APNGFrame *frame = [[APNGFrame alloc] initWithFctl:[[APNGFCTL alloc] initWithData:[self.data subdataWithRange:NSMakeRange(obj.start + 8, obj.length - 12)]]  data:dataChunks];
            [self.frames addObject:frame];
        }
    }];
}

- (APNGACTL *)resolveACTLWithChunk:(APNGChunk *)chunk
{
    NSAssert([chunk.type isEqualToString:@"acTL"], @"chunk type must be acTL");
    return [[APNGACTL alloc] initWithData:[_data subdataWithRange:NSMakeRange(chunk.start + 8, chunk.length - 12)]];
}

- (APNGIHDR *)resolveIHDRWithChunk:(APNGChunk *)chunk
{
    NSAssert([chunk.type isEqualToString:@"IHDR"], @"chunk type must be IHDR");
    return [[APNGIHDR alloc] initWithData:[_data subdataWithRange:NSMakeRange(chunk.start + 8, chunk.length - 12)]];
}

- (CGImageRef )decodeImageOfIndex:(NSUInteger)index
{
    NSAssert(index < _frames.count, @"index beyond frames count");
    APNGFrame *frame = _frames[index];
    NSData *data = [_assembler getPNGDataWithFrame:frame data:_data];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, nil);
    CGImageRef originalImage = CGImageSourceCreateImageAtIndex(source, 0, nil);
    if (!originalImage)
    {
        return nil;
    }
    if (!_context)
    {
        UIGraphicsBeginImageContext(CGSizeMake(self.ihdr.width, self.ihdr.height));
        _context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(_context, 0, self.ihdr.height);
        CGContextScaleCTM(_context, 1.0, -1.0);
    }
    CGImageRef image = nil;
    UInt32 offsetY = self.ihdr.height - frame.fctl.y_offset - frame.fctl.height;
    CGRect fullRect = CGRectMake(0, 0, self.ihdr.width, self.ihdr.height);
    CGRect drawRect = CGRectMake(frame.fctl.x_offset, offsetY, frame.fctl.width, frame.fctl.height);
    
    switch (frame.fctl.dispose_op) {
        case APNG_DISPOSE_OP_none:
        {
            if (frame.fctl.blend_op == APNG_BLEND_OP_source)
            {
                CGContextClearRect(_context, drawRect);
            }
            
            CGContextDrawImage(_context, drawRect, originalImage);
            //[originalUIImage drawInRect:drawRect];
            
            image = CGBitmapContextCreateImage(_context);
        }
            break;
        case APNG_DISPOSE_OP_background:
        {
            if (frame.fctl.blend_op == APNG_BLEND_OP_source)
            {
                CGContextClearRect(_context, drawRect);
            }
            CGContextDrawImage(_context, drawRect, originalImage);
            //[originalUIImage drawInRect:drawRect];
            
            image = CGBitmapContextCreateImage(_context);
            CGContextClearRect(_context, drawRect);
        }
            break;
        case APNG_DISPOSE_OP_previous:
        {
            CGImageRef previousImage = CGBitmapContextCreateImage(_context);
            //UIImage *previousUIImage = [UIImage imageWithCGImage:previousImage];
            
            if (frame.fctl.blend_op == APNG_BLEND_OP_source)
            {
                CGContextClearRect(_context, drawRect);
            }
            CGContextDrawImage(_context, drawRect, originalImage);
            //[originalUIImage drawInRect:drawRect];
            
            image = CGBitmapContextCreateImage(_context);
            if (previousImage)
            {
                CGContextClearRect(_context, fullRect);
                CGContextDrawImage(_context, fullRect, previousImage);
                //[previousUIImage drawInRect:fullRect];
            }
        }
            break;
        default:
            break;
    }
    
    CGImageRelease(originalImage);
    CFRelease(source);
    CGDataProviderRelease(provider);
    return image;
}

- (APNGAnimatedImage *)getImageOfIndex:(NSUInteger)index
{
    CGImageRef image = [self decodeImageOfIndex:index];
    if (!image)
    {
        return nil;
    }
    double duration = (double)_frames[index].fctl.delay_num / (double)_frames[index].fctl.delay_den;
    UIImage *imageObj = [UIImage imageWithCGImage:image];
    return [[APNGAnimatedImage alloc] initWithImage:imageObj duration:duration];
}

- (NSUInteger)numberOfFrames
{
    return _actl.numOfFrames;
}

- (NSUInteger)numberOfPlays
{
    return _actl.numOfPlays;
}

- (void)dealloc
{
    UIGraphicsEndImageContext();
}

@end




