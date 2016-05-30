//
//  ZCImagePickerDelegate.h
//  MyImageController
//
//  Created by zhao.feng on 16/5/27.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZCImagePickerDelegate <NSObject>

- (void)zc_ImagePickerDidFinishPickingImage:(NSArray *)images;

@end
