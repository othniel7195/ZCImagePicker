//
//  ZCPhotoManager.m
//  MyImageController
//
//  Created by zhao.feng on 16/5/23.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import "ZCPhotoManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ZCAlbumModel.h"
#import "ZCPhotoModel.h"

static inline ZCImageType zc_ImageTypeFromData(NSData *imageData)
{
    if (imageData.length > 4) {
        const unsigned char * bytes = [imageData bytes];
        
        if (bytes[0] == 0xff &&
            bytes[1] == 0xd8 &&
            bytes[2] == 0xff)
        {
            return ZCImageType_JPEG;
        }
        
        if (bytes[0] == 0x89 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x4e &&
            bytes[3] == 0x47)
        {
            return ZCImageType_PNG;
        }
    }
    
    return ZCImageType_Unknown;
}


@implementation ZCPhotoManager

- (BOOL)zc_AuthorizationStatusAuthorized {
    
    if (iOS8Later) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) return YES;
    } else {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) return YES;
    }
    return NO;
}
-(void)zc_RequestAuthorization:(void (^)(BOOL result, BOOL alert ,NSArray * allAlbum))authorizationCompletion;
{
    
    if (iOS8Later) {
        
       __block NSMutableArray *albums = [[NSMutableArray alloc] init];
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            switch (status) {
                case PHAuthorizationStatusNotDetermined:
                {
                   
                    
                    if (authorizationCompletion) {
                        
                        authorizationCompletion(NO,NO,albums);
                    }
                    
                    break;
                }
                case PHAuthorizationStatusRestricted   :
                case PHAuthorizationStatusDenied       : {
                    
                    
                    
                    if (authorizationCompletion) {
                        
                        authorizationCompletion(NO,YES,albums);
                    }
                    
                    break;
                }
                case PHAuthorizationStatusAuthorized: {
                    
                    
                    albums = [self zc_IOS8LaterGetAllAlbum];
                    
                    if (authorizationCompletion) {
                        
                        authorizationCompletion(YES,NO,albums);
                    }
                    
                    break;
                }
            }
        }];
    }
    else
    {
        
        NSMutableArray *albums = [[NSMutableArray alloc] init];
        
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
            
            switch ([ALAssetsLibrary authorizationStatus]) {
                case ALAuthorizationStatusNotDetermined:
                {
                    authorizationCompletion(NO,NO,albums);
                    
                    break;
                }
                    
                case ALAuthorizationStatusRestricted:
                case ALAuthorizationStatusDenied:
                {
                    authorizationCompletion(NO,YES,albums);
                    break;
                }
                default:
                    break;
            }
            
        };
        
        
        [self zc_BeforeIOS8GetAllAlbum:failureBlock albums:^(NSArray *allAlbum) {
            
            if (allAlbum.count > 0) {
                
                if (authorizationCompletion) {
                    authorizationCompletion(YES,NO,allAlbum);
                }
                
            }
            else
            {
                if (authorizationCompletion) {
                    authorizationCompletion(NO,NO,allAlbum);
                }
                
            }
            
        }];
        
        
    }
    
    
}


/**
 *  IOS8 Later 获取所有相册
 *
 *  @return
 */
-(NSMutableArray *)zc_IOS8LaterGetAllAlbum
{
    NSMutableArray *albums = [[NSMutableArray alloc] init];
    
    PHAssetCollectionSubtype smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded |
    PHAssetCollectionSubtypeSmartAlbumFavorites |
    PHAssetCollectionSubtypeSmartAlbumPanoramas |
    PHAssetCollectionSubtypeSmartAlbumAllHidden |
    PHAssetCollectionSubtypeSmartAlbumBursts;
    if (iOS9Later) {
        smartAlbumSubtype = smartAlbumSubtype |PHAssetCollectionSubtypeSmartAlbumScreenshots | PHAssetCollectionSubtypeSmartAlbumSelfPortraits ;
    }
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeImage];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:smartAlbumSubtype options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        
        //查询相册中需要的图片资源
        PHFetchResult *asset = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        if (asset.count < 1) return ;
        
        if ([collection.localizedTitle isEqualToString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) return;
        
        if ([collection.localizedTitle isEqualToString:@"Camera Roll"] || [collection.localizedTitle isEqualToString:@"相机胶卷"]) {
            
            ZCAlbumModel *albumM = [self zc_transformToAlbumModel:asset albumName:collection.localizedTitle];
            
            if (albumM) {
                [albums insertObject:albumM atIndex:0];
            }
            
        }
        else
        {
            ZCAlbumModel *albumM = [self zc_transformToAlbumModel:asset albumName:collection.localizedTitle];
            if (albumM) {
                
                [albums addObject:albumM];
            }
            
        }
        
    }];
    
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedFaces |PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHFetchResult *asset = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        if (asset.count < 1) return ;
        
        if ([collection.localizedTitle isEqualToString:@"My Photo Stream"] || [collection.localizedTitle isEqualToString:@"我的照片流"])
        {
            ZCAlbumModel *albumM = [self zc_transformToAlbumModel:asset albumName:collection.localizedTitle];
            if (albumM) {
                [albums insertObject:albumM atIndex:1];
            }
            
        }
        else
        {
            ZCAlbumModel *albumM = [self zc_transformToAlbumModel:asset albumName:collection.localizedTitle];
            if (albumM) {
                [albums addObject:albumM];
            }
            
        }
        
    }];
    
    
    return albums;
}


- (void)zc_BeforeIOS8GetAllAlbum:(ALAssetsLibraryAccessFailureBlock)failureBlock albums:(void (^)(NSArray * allAlbum))completion;

{
    

    NSMutableArray *albums = [[NSMutableArray alloc] init];
    
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        
        if (group && [group numberOfAssets] > 0) {
            
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            
            if ([name isEqualToString:@"Camera Roll"] || [name isEqualToString:@"相机胶卷"]) {
                ZCAlbumModel *albumM = [self zc_transformToAlbumModel:group albumName:name];
                if (albumM) {
                    [albums insertObject:albumM atIndex:0];
                }
                
            } else if ([name isEqualToString:@"My Photo Stream"] || [name isEqualToString:@"我的照片流"]) {
                
                ZCAlbumModel *albumM = [self zc_transformToAlbumModel:group albumName:name];
                if (albumM) {
                    [albums insertObject:albumM atIndex:1];
                }
                
            } else {
                ZCAlbumModel *albumM = [self zc_transformToAlbumModel:group albumName:name];
                if (albumM) {
                    [albums addObject:albumM];
                }
                
            }
           
            if (completion) {
                completion(albums);
            }
            
        }
    };
    
  
    
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                 usingBlock:resultsBlock
                               failureBlock:failureBlock];
    
}

- (void)zc_GetAllAlbum:(void (^)(NSArray * allAlbum))completion;

{
    if (iOS8Later) {
        
        NSMutableArray *albums = [[NSMutableArray alloc] init];
        albums = [self zc_IOS8LaterGetAllAlbum];
        
        if (completion) {
            completion(albums);
        }
    }
    else
    {
        [self zc_BeforeIOS8GetAllAlbum:nil albums:^(NSArray *allAlbum) {
            
            if (completion) {
                completion(allAlbum);
            }
            
        }];
        
    }
    
}





/**
 *  转换成AlbumModel
 *
 *  @param result 相册  PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
 *
 *  @return AlbumModel
 */
- (ZCAlbumModel *)zc_transformToAlbumModel:(id)result albumName:(NSString *)albumName
{
    

    NSArray *photos = [self zc_getAllPhotosWithAlbum:result];
    
    if (photos.count < 1) {
        
        return nil;
    }
    ZCAlbumModel *albumM = [[ZCAlbumModel alloc] init];
    albumM.albumName = [self zc_GetNewAlbumName:albumName];
    albumM.photos = photos;
    
    return albumM;
}

/**
 *  转中文名字
 *
 *  @param name
 *
 *  @return
 */
- (NSString *)zc_GetNewAlbumName:(NSString *)name {
    NSString *newName;
    if ([name rangeOfString:@"Roll"].location != NSNotFound)
        newName = @"相机胶卷";
    else if ([name rangeOfString:@"Stream"].location != NSNotFound)
        newName = @"我的照片流";
    else if ([name rangeOfString:@"Added"].location != NSNotFound)
        newName = @"最近添加";
    else if ([name rangeOfString:@"Selfies"].location != NSNotFound)
        newName = @"自拍";
    else if ([name rangeOfString:@"shots"].location != NSNotFound)
        newName = @"截屏";
    else if ([name rangeOfString:@"Panoramas"].location != NSNotFound)
        newName = @"全景照片";
    else if ([name rangeOfString:@"Favorites"].location != NSNotFound)
        newName = @"个人收藏";
    else if ([name rangeOfString:@"Hidden"].location != NSNotFound)
        newName = @"隐藏的照片";
    else if ([name rangeOfString:@"Bursts"].location != NSNotFound)
        newName = @"连拍";
    else newName = name;
    return newName;
    
}


- (NSArray *)zc_getAllPhotosWithAlbum:(id)album
{
    NSMutableArray * photos = [[NSMutableArray alloc] init];
    
    if ([album isKindOfClass:[PHFetchResult class]]) {
        
        PHFetchResult *fetchResult =  (PHFetchResult *)album;
        
        [fetchResult enumerateObjectsUsingBlock:^(PHAsset *  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (iOS9_1Later) {
                if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                    
                    return ;
                }
                
            }
            if ((asset.mediaType == PHAssetMediaTypeImage)) {
                
                
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
                options.synchronous = YES;
                
                
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    
                    
                    
                    if (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]) {
                        
                        if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData) {
                            
                            NSLog(@"没有图片  可能要从icloud中下载");
                            //TODO:暂时不考虑下载
                        }
                        else
                        {
                            if (imageData) {
                                
                                ZCPhotoModel *photoM = [[ZCPhotoModel alloc] init];
                                photoM.image = [[UIImage alloc] initWithData:imageData];
                                photoM.pixelWidth = asset.pixelWidth;
                                photoM.pixelHeight = asset.pixelHeight;
                                photoM.imageType = zc_ImageTypeFromData(imageData);
                                
                                [photos addObject:photoM];
                                
                            }
                            else
                            {
                                NSLog(@"图片未获取到");
                            }
                        }
                    }
                    
                }];
                
                
            }
            
            
        }];
        
    }
    else if([album isKindOfClass:[ALAssetsGroup class]])
    {
        [album enumerateAssetsUsingBlock:^(ALAsset *  _Nonnull alAsset, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (alAsset) {
                
                ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
                
                Byte *imageBuffer = (Byte*)malloc((unsigned long)assetRep.size);
                NSUInteger bufferSize = [assetRep getBytes:imageBuffer fromOffset:0.0 length:(unsigned long)assetRep.size error:nil];
                NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
                
                if (imageData) {
                    
                    ZCPhotoModel *photoM = [[ZCPhotoModel alloc] init];
                    photoM.image = [[UIImage alloc] initWithData:imageData];
                    photoM.pixelWidth = assetRep.dimensions.width;
                    photoM.pixelHeight = assetRep.dimensions.height;
                    photoM.imageType = zc_ImageTypeFromData(imageData);
                    [photos addObject:photoM];
                    
                }
                else
                {
                    NSLog(@"图片未获取到");
                }
            }
        }];
    }
    
    
    return photos;
}

@end
