//
//  ZCAlbumInfoController.m
//  MyImageController
//
//  Created by zhao.feng on 16/5/23.
//  Copyright © 2016年 com.zhaofeng. All rights reserved.
//

#import "ZCAlbumInfoViewController.h"
#import "ZCPhotosViewController.h"
#import "ZCAlbumModel.h"
#import "ZCAlbumInfoCell.h"

@interface ZCAlbumInfoViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)UITableView *albumInfoTable;


@end

@implementation ZCAlbumInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self loadContentViews];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark -- life cycle
-(void)loadContentViews
{
    self.navigationItem.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelDone)];
    
    [self.view addSubview:self.albumInfoTable];
    
    
    
}
-(void)reloadAlbums
{
    [self.albumInfoTable reloadData];
}

#pragma mark -- private method
-(void)cancelDone
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- table dataSource delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albums.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"albumInfoCell";
    ZCAlbumInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        
        cell = [[ZCAlbumInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ZCAlbumModel *albumM = self.albums[indexPath.row];
    cell.coverImageView.image = albumM.coverImage;
    
    NSString *albumName = albumM.albumName;
    NSString *albumCount = [NSString stringWithFormat:@"(%ld)",(long)albumM.count];
    NSString *text = [NSString stringWithFormat:@"%@  %@",albumName,albumCount];
    
    NSMutableAttributedString *attriText =[[NSMutableAttributedString alloc] initWithString:text];
    [attriText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[text rangeOfString:albumName]];
    [attriText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:[text rangeOfString:albumName]];
    [attriText addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:[text rangeOfString:albumCount]];
    [attriText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:[text rangeOfString:albumCount]];
    
    cell.infoLabel.attributedText = attriText;
    
    cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZCPhotosViewController *photosVC = [[ZCPhotosViewController alloc] init];
    photosVC.singleSelect = self.singleSelect;
    photosVC.albumModel = self.albums[indexPath.row];
    [self.navigationController pushViewController:photosVC animated:YES];

}

#pragma mark -- table init
-(UITableView *)albumInfoTable
{
    if (!_albumInfoTable) {
        UITableView * tempTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tempTable.dataSource = self;
        tempTable.delegate = self;
        
        _albumInfoTable = tempTable;
    }
    
    return _albumInfoTable;
}

@end
