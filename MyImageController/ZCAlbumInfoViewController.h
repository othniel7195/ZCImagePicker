//
//  ZCAlbumInfoController.h
//  MyImageController
//
//  Created by zhao.feng on 16/5/23.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCAlbumInfoViewController : UIViewController
@property(nonatomic, strong)NSArray *albums;
/**
 *  是否只能单选  默认 NO  可多选
 */
@property(nonatomic, assign)BOOL singleSelect;

-(void)reloadAlbums;
@end
