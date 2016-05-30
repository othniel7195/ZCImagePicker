//
//  ZCImageController.h
//  MyImageController
//
//  Created by zhao.feng on 16/5/23.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//
// 只支持相册Image的选取

#import <UIKit/UIKit.h>
#import "ZCImagePickerDelegate.h"

@class ZCPhotoManager;

@interface ZCImagePickerController : UINavigationController 

@property(nonatomic , weak) id <ZCImagePickerDelegate> pickerDelegate;

/**
 *  nav bar  颜色设置
 */
@property(nonatomic, strong)UIColor *navigationBarColor;

/**
 *  筛选规则 暂时只支持图片格式(PNG,JPEG) ,图像长宽的筛选
 *
 *  @param predicate 筛选规则
 @  @param singleSelect 默认 NO 多选  YES 单选 
 *
 *  @return
 */
- (instancetype)initWithPredicate:(NSPredicate *)predicate singleSelect:(BOOL)singleSelect;

@end
