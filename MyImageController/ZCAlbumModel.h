//
//  ZCAlbumModel.h
//  MyImageController
//
//  Created by zhao.feng on 16/5/26.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <UIKit/UIKit.h>


@interface ZCAlbumModel : NSObject

/**
 *  相册名字
 */
@property(nonatomic, strong)NSString *albumName;
/**
 *  照片数量
 */
@property(nonatomic, assign)NSInteger count;
/**
 *  相册封面
 */
@property(nonatomic, strong)UIImage *coverImage;


/**
 *  图像资源
 */
@property(nonatomic, strong)NSArray *photos;

@end
