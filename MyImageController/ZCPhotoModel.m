//
//  ZCPhotoModel.m
//  MyImageController
//
//  Created by zhao.feng on 16/5/26.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import "ZCPhotoModel.h"

@implementation ZCPhotoModel


- (NSString *)description
{
    return [NSString stringWithFormat:@"imageType:%ld image.size:%@",(long)_imageType,NSStringFromCGSize(_image.size)];
}
@end
