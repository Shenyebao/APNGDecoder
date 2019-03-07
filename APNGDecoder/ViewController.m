//
//  ViewController.m
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/1.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import "ViewController.h"
#import "OCAPNGDecoder.h"
#import "APNGStructure.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"apng3" ofType:@"png" inDirectory:@"res"];
    NSData *data = [NSData dataWithContentsOfFile:path];
//    UIImage *image = [UIImage imageWithData:data];
//    [self.view addSubview:[[UIImageView alloc] initWithImage:image]];

    OCAPNGDecoder *decoder = [[OCAPNGDecoder alloc] initWithData:data];
    [decoder startDecoding];
    NSUInteger num = [decoder numberOfFrames];
    NSMutableArray<UIImage *> *imageArray = [NSMutableArray arrayWithCapacity:num];
    NSMutableArray<NSNumber *> *durationArray = [NSMutableArray arrayWithCapacity:num];
    for (int i = 0; i < num; i++)
    {
        APNGAnimatedImage *image = [decoder images][i];
        [imageArray addObject:image.image];
        if (image.duration > 0)
        {
            NSLog(@"%d duration %lf",i,image.duration);
        }
        [durationArray addObject:@(image.duration)];
    }
    UIImageView *view = [[UIImageView alloc] initWithImage:imageArray[0]];
    //view.frame = self.view.bounds;
    view.animationImages = imageArray;
    view.animationDuration = 2.5;
    view.animationRepeatCount = HUGE_VAL;
    [self.view addSubview:view];
    [view startAnimating];
    
    
}


@end
