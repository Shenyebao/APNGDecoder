//
//  APNGStructure.h
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/1.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
 Structure of an APNG chunk
 A chunk consists of four parts:
 ---------------------------------------------------------------------------
 
 Length (4 bytes),
 Chunk type (4 bytes),
 Chunk data (length bytes),
 CRC (Cyclic Redundancy Code / Checksum, 4 bytes).
 
 ---------------------------------------------------------------------------
 */
@interface APNGChunk : NSObject
// Chunk length, not the data length (which is length - 12)
@property (nonatomic, assign) UInt32 length;
// Chunk type
@property (nonatomic, copy) NSString *type;
// Chunk data: start index of apng file data
@property (nonatomic, assign) NSUInteger start;
// Chunk data: end index of apng file data
@property(nonatomic, assign) NSUInteger end;

- (id)initWithLength:(UInt32)length type:(NSString *)type start:(NSUInteger )start end:(NSUInteger)end;

@end

/*
 Structure of an APNG actl
 The `acTL` chunk is an ancillary chunk as defined in the PNG Specification. It must appear before the first `IDAT` chunk within a valid PNG stream.
 num_frames     (unsigned int)    Number of frames
 num_plays      (unsigned int)    Number of times to loop this APNG.  0 indicates infinite looping.
 */
@interface APNGACTL : NSObject

@property (nonatomic, assign) UInt32 numOfFrames;
@property (nonatomic, assign) UInt32 numOfPlays;

- (id)initWithFrames:(UInt32)frames plays:(UInt32)plays;

- (id)initWithData:(NSData *)data;

@end

/**
 The IHDR chunk shall be the first chunk in the PNG datastream. It contains:
 
 Width                           4 bytes
 Height                          4 bytes
 Bit depth                       1 byte
 Colour type                     1 byte
 Compression method              1 byte
 Filter method                   1 byte
 Interlace method                1 byte
 
 */

@interface APNGIHDR : NSObject
@property (nonatomic, assign) UInt32 width;
@property (nonatomic, assign) UInt32 height;
@property (nonatomic, assign) UInt8 bitDepth;
@property (nonatomic, assign) UInt8 colorType;
@property (nonatomic, assign) UInt8 compressMethod;
@property (nonatomic, assign) UInt8 filterMethod;
@property (nonatomic, assign) UInt8 interlaceMethod;

- (id)initWithWidth:(UInt32)width height:(UInt32)height bitDepth:(UInt8)bitDepth colorType:(UInt8)colorType compressMethod:(UInt8)compressMethod filterMethod:(UInt8)filterMethod interlaceMethod:(UInt8)interlaceMethod;

- (id)initWithData:(NSData *)data;

@end

/**
 The `fcTL` chunk is an ancillary chunk as defined in the PNG Specification. It must appear before the `IDAT` or `fdAT` chunks of the frame to which it applies, specifically:
 
 For the default image, if a `fcTL` chunk is present it must appear before the first `IDAT` chunk. Position relative to the `acTL` chunk is not specified.
 For the first frame excluding the default image (which may be either the first or second frame), the `fcTL` chunk must appear after all `IDAT` chunks and before the `fdAT` chunks for the frame.
 For all subsequent frames, the `fcTL` chunk for frame N must appear after the `fdAT` chunks from frame N-1 and before the `fdAT` chunks for frame N.
 Other ancillary chunks are allowed to appear among the APNG chunks, including between `fdAT` chunks.
 Exactly one `fcTL` chunk is required for each frame.
 
 Format:
 
 byte
 0    sequence_number       (unsigned int)   Sequence number of the animation chunk, starting from 0
 4    width                 (unsigned int)   Width of the following frame
 8    height                (unsigned int)   Height of the following frame
 12    x_offset              (unsigned int)   X position at which to render the following frame
 16    y_offset              (unsigned int)   Y position at which to render the following frame
 20    delay_num             (unsigned short) Frame delay fraction numerator
 22    delay_den             (unsigned short) Frame delay fraction denominator
 24    dispose_op            (byte)           Type of frame area disposal to be done after rendering this frame
 25    blend_op              (byte)           Type of frame area rendering for this frame
 
 */

@interface APNGFCTL : NSObject
@property (nonatomic, assign) UInt32 sequence_number;
@property (nonatomic, assign) UInt32 width;
@property (nonatomic, assign) UInt32 height;
@property (nonatomic, assign) UInt32 x_offset;
@property (nonatomic, assign) UInt32 y_offset;
@property (nonatomic, assign) UInt16 delay_num;
@property (nonatomic, assign) UInt16 delay_den;
@property (nonatomic, assign) UInt8 dispose_op;
@property (nonatomic, assign) UInt8 blend_op;

- (id)initWithSeq:(UInt32)seq width:(UInt32)width height:(UInt32)height xOffset:(UInt32)xOffset yOffset:(UInt32)yOffset delayNum:(UInt16)delayNum delayDen:(UInt16)delayDen disposeOp:(UInt8)disposeOp blendOp:(UInt8)blendOp;

- (id)initWithData:(NSData *)data;

@end

@interface APNGFrame : NSObject

@property (nonatomic, strong) APNGFCTL *fctl;
/**
 each frame could contain multiple IDAT/fdAT chunks
 */
@property (nonatomic, strong) NSArray<APNGChunk *> *dataChunks;

- (id)initWithFctl:(APNGFCTL *)fctl data:(NSArray<APNGChunk *> *)chunks;

@end

@interface APNGAnimatedImage : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) double duration;

- (id)initWithImage:(UIImage *)image duration:(double)duration;

@end

NS_ASSUME_NONNULL_END
