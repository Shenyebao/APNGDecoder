//
//  APNGDefine.h
//  APNGDecoder
//
//  Created by louisysshen(沈亦舒) on 2019/3/1.
//  Copyright © 2019 louisysshen(沈亦舒). All rights reserved.
//

#ifndef APNGDefine_h
#define APNGDefine_h

/*
 APNG_DISPOSE_OP_NONE: no disposal is done on this frame before rendering the next; the contents of the output buffer are left as is.
 APNG_DISPOSE_OP_BACKGROUND: the frame's region of the output buffer is to be cleared to fully transparent black before rendering the next frame.
 APNG_DISPOSE_OP_PREVIOUS: the frame's region of the output buffer is to be reverted to the previous contents before rendering the next frame.
 */

typedef NS_ENUM(UInt8, APNG_DISPOSE_OP) {
    ///nothing to do before render next frame
    APNG_DISPOSE_OP_none = 0,
    ///clear region before render next frame
    APNG_DISPOSE_OP_background = 1,
    ///restore content with previous before render next frame
    APNG_DISPOSE_OP_previous = 2,
};
/*
 If `blend_op` is APNG_BLEND_OP_SOURCE all color components of the frame, including alpha, overwrite the current contents of the frame's output buffer region. If `blend_op` is APNG_BLEND_OP_OVER the frame should be composited onto the output buffer based on its alpha, using a simple OVER operation as described in the "Alpha Channel Processing" section of the PNG specification [PNG-1.2]. Note that the second variation of the sample code is applicable.
 */
typedef NS_ENUM(NSUInteger, APNG_BLEND_OP) {
    APNG_BLEND_OP_source = 0,
    APNG_BLEND_OP_over = 1,
};


#endif /* APNGDefine_h */
