//
//  ViewController.m
//  MyImageController
//
//  Created by zhao.feng on 16/5/20.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import "ViewController.h"
#import "ZCImagePickerController.h"

@interface ViewController ()<ZCImagePickerDelegate>

@property(nonatomic, strong)UIImageView *testImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn =[[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 40)];
    btn.backgroundColor =[UIColor redColor];
    [btn setTitle:@"打开相册" forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(openXiangCe) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:btn];
    
    
    self.testImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, 120, 120)];
    self.testImageView.backgroundColor =[UIColor yellowColor];
    [self.view addSubview:self.testImageView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


-(void)openXiangCe
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"imageType = %ld AND pixelWidth >= 3000",0];
    ZCImagePickerController *picker =[[ZCImagePickerController alloc] initWithPredicate:pre singleSelect:NO];
    
    picker.pickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)zc_ImagePickerDidFinishPickingImage:(NSArray *)images
{
   
    self.testImageView.image = [images firstObject];
}

@end
