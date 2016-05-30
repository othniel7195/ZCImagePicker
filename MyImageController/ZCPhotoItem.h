//
//  ZCPhotoItem.h
//  MyImageController
//
//  Created by zhao.feng on 16/5/23.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZCPhotoItemSelected)(NSInteger row);
typedef void(^ZCPhotoItemCancle)(NSInteger row);

@interface ZCPhotoItem : UICollectionViewCell

@property(nonatomic, strong)UIImage *photo;
@property(nonatomic, assign)NSInteger row;
@property(nonatomic, copy)ZCPhotoItemSelected selectedBlock;
@property(nonatomic, copy)ZCPhotoItemCancle cancleBlock;

/**
 *  选择按钮是否隐藏
 */
@property(nonatomic, assign)BOOL hidden;

@end
