//
//  APNGAnimationView.h
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/6.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APNGAnimationView : UIImageView

- (id) init __attribute__((unavailable("init not available, call initWithAPNGFile instead")));

- (id)initWithAPNGFile:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
