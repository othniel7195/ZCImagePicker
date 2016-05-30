//
//  ZCImageController.m
//  MyImageController
//
//  Created by zhao.feng on 16/5/23.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import "ZCImagePickerController.h"
#import "ZCAlbumInfoViewController.h"
#import "ZCPhotosViewController.h"
#import "ZCPhotoManager.h"

@interface ZCImagePickerController ()

@end

@implementation ZCImagePickerController

- (instancetype)initWithPredicate:(NSPredicate *)predicate singleSelect:(BOOL)singleSelect
{
    self = [self initWithRootViewControllerWithPredicate:predicate singleSelect:singleSelect];
    if (!self)  return nil;
    
    
    return self;
}

- (instancetype)init
{
    self = [self initWithRootViewControllerWithPredicate:nil singleSelect:NO];
    if (!self)  return nil;
    
    
    return self;
}

/**
 *
 *
 *  @param rootViewController
 *  @param predicate          查询条件
 *  @param singleSelect  单选 多选
 *  @return
 */
- (instancetype)initWithRootViewControllerWithPredicate:(NSPredicate *)predicate singleSelect:(BOOL)singleSelect

{
    
    ZCPhotoManager *photoManager = [[ZCPhotoManager alloc] init];
    
    ZCAlbumInfoViewController *albumInfoVC = [[ZCAlbumInfoViewController alloc] init];
    self = [super initWithRootViewController:albumInfoVC];
    
    if (!self)  return nil;
    
    [self pushPhotoViewController:albumInfoVC photoManager:photoManager predicate:predicate singleSelect:singleSelect];
    
    
    return self;
}


/**
 *  筛选相册
 *
 *  @param albums
 *  @param predicate
 *
 *  @return
 */
-(NSMutableArray *)siftAlbums:(NSArray *)albums predicate:(NSPredicate *)predicate
{
    NSMutableArray * tempAlbums = [[NSMutableArray alloc] init];
    
    if (predicate) {
        
        [albums enumerateObjectsUsingBlock:^(ZCAlbumModel *  _Nonnull albumM, NSUInteger idx, BOOL * _Nonnull stop) {
            
            albumM.photos = [albumM.photos filteredArrayUsingPredicate:predicate];
            
            
            if (albumM.photos.count >0) {
                
                [tempAlbums addObject:albumM];
            }
            
        }];
        
    }

    return tempAlbums;
}


-(void)pushPhotoViewController:(ZCAlbumInfoViewController *)albumInfoVC
                  photoManager:(ZCPhotoManager *)photoManager
                  predicate:(NSPredicate *)predicate
                  singleSelect:(BOOL)singleSelect


{
    if ([photoManager zc_AuthorizationStatusAuthorized]) {
        
        [photoManager zc_GetAllAlbum:^(NSArray *allAlbum) {
            
            NSMutableArray *newAlbums =  [self siftAlbums:allAlbum predicate:predicate];
            
            albumInfoVC.singleSelect = singleSelect;
            albumInfoVC.albums = newAlbums;
            ZCPhotosViewController *photosVC = [[ZCPhotosViewController alloc] init];
            photosVC.singleSelect = singleSelect;
            
            photosVC.albumModel = [newAlbums firstObject];
            
            
            if (iOS8Later) {
                [self pushViewController:photosVC animated:YES];
            }
            else
            {
                self.viewControllers = @[albumInfoVC,photosVC];
            }
        
            
        }];
        
    }
    else
    {
        
        albumInfoVC.singleSelect = singleSelect;
        ZCPhotosViewController *photosVC = [[ZCPhotosViewController alloc] init];
        photosVC.singleSelect = singleSelect;
        
        [self pushViewController:photosVC animated:YES];
        
        
        [photoManager zc_RequestAuthorization:^(BOOL result ,BOOL alert,NSArray *albums) {
            
            if (result) {
                
                NSMutableArray *newAlbums =  [self siftAlbums:albums predicate:predicate];
                
                albumInfoVC.albums = newAlbums;
                
                photosVC.albumModel = [newAlbums firstObject];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [albumInfoVC reloadAlbums];
                    [photosVC reloadPhotos];
                });
                
                
            }
            
            else
            {
                
                if (alert) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有看相册的权限" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                    });
                    
                }
                else
                {
                    
                }
                
            }
            
        }];
        
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor =[UIColor whiteColor];
    if (self.navigationBarColor) {
        self.navigationBar.barTintColor = self.navigationBarColor;
    }
    else
    {
      self.navigationBar.barTintColor = [UIColor blackColor];
    }
    
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imagePickerDidFinish:) name:@"zcImagePickerFinish" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"zcImagePickerFinish" object:nil];
    
}

-(void)imagePickerDidFinish:(NSNotification *)objc
{
    NSArray *images = objc.object;
    
    if (images.count > 0) {
        
        [self.pickerDelegate zc_ImagePickerDidFinishPickingImage:images];
    }
}

@end
