//
//  APNGAnimationView.m
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/6.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import "APNGAnimationView.h"
#import "OCAPNGDecoder.h"
#import "APNGStructure.h"

@interface APNGAnimationView()

@property (nonatomic, strong) NSMutableArray<UIImage *> *images;
@property (nonatomic, strong) OCAPNGDecoder *decoder;

@end

@implementation APNGAnimationView

- (id)initWithAPNGFile:(NSString *)path
{
    if (self = [super init])
    {
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.decoder = [[OCAPNGDecoder alloc] initWithData:data];
    }
    return self;
}

- (void)decodeImages
{
    [_decoder startDecoding];
    [[_decoder images] enumerateObjectsUsingBlock:^(APNGAnimatedImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
}

@end
