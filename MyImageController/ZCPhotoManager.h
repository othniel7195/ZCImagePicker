//
//  ZCPhotoManager.h
//  MyImageController
//
//  Created by zhao.feng on 16/5/23.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)


@interface ZCPhotoManager : NSObject

/**
 *  相册权限判断
 *
 *  @return  YES 权限OK  NO 权限禁止
 */
- (BOOL)zc_AuthorizationStatusAuthorized;

/**
 *  相册权限检测  当权限OK 返回相册信息
 *
 *  result  YES 权限OK  NO 权限禁止
 *  alert 是否需要弹窗
 */
-(void)zc_RequestAuthorization:(void (^)(BOOL result, BOOL alert ,NSArray * allAlbum))authorizationCompletion;

/**
 *  获取所有相册信息
 */
- (void)zc_GetAllAlbum:(void (^)(NSArray * allAlbum))completion;


@end
