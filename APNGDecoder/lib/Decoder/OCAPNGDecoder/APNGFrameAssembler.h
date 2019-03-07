//
//  APNGFrameAssembler.h
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/4.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import <Foundation/Foundation.h>

@class APNGChunk;
@class APNGFrame;

NS_ASSUME_NONNULL_BEGIN

@interface APNGFrameAssembler : NSObject

- (void)addChunkBefore:(APNGChunk *)chunk;

- (void)addChunkAfter:(APNGChunk *)chunk;

- (NSData *)getPNGDataWithFrame:(APNGFrame *)frame data:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
