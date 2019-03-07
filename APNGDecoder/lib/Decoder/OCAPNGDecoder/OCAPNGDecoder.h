//
//  OCAPNGDecoder.h
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/1.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import <Foundation/Foundation.h>

@class APNGAnimatedImage;

NS_ASSUME_NONNULL_BEGIN

@interface OCAPNGDecoder : NSObject

- (id)initWithData:( NSData * _Nonnull )data;

- (NSUInteger)numberOfFrames;

- (NSUInteger)numberOfPlays;

- (void)startDecoding;

- (NSArray <APNGAnimatedImage *> *)images;

@end

NS_ASSUME_NONNULL_END
