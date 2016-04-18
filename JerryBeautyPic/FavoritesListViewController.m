//
//  FavoritesListViewController.m
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/24.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#import "FavoritesListViewController.h"
#import "FileOperationHelper.h"
#import "Header.h"

@implementation FavoritesListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadData];
    
    [self initView];
}

- (void)loadData
{
    self.favoriteImageArray = [[NSMutableArray alloc] init];
    self.favoriteImagePathArray = [[NSMutableArray alloc] init];
    
    NSArray *fileNameArray = [FileOperationHelper getAllFileNameInDocumentByDocumentName:DIR_NAME_IMAGES];
    
    if (fileNameArray != nil && [fileNameArray count] > 0) {
        //有收藏图片
        for (NSString *fileName in fileNameArray) {
            //获取沙盒存储路径
            NSString *savePath = [FileOperationHelper getPictureSavePathByDocumentName:DIR_NAME_IMAGES andImageName:fileName];
            
            UIImage *favoriteImage = [[UIImage alloc] initWithContentsOfFile:savePath];
            //图片
            [self.favoriteImageArray addObject:favoriteImage];
            //图片路径
            [self.favoriteImagePathArray addObject:savePath];
        }
        
        [self.favoriteListTableView reloadData];
    }else{
        //没有收藏图片,添加没有图片收藏提示
        self.favoriteListTableView.hidden = YES;
        [self setTipsInScreenCenter];
    }
}

- (void)initView
{
    self.navigationItem.title = @"收藏夹";
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.favoriteListTableView.delegate = self;
    self.favoriteListTableView.dataSource = self;
}

#pragma mark 屏幕中央添加提示语
- (void)setTipsInScreenCenter
{
    UILabel *tips = [[UILabel alloc] init];
    tips.text = @"还没有收藏哦，赶紧收藏下吧~";
    tips.textColor = [UIColor grayColor];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat tipsWidth = 300;
    CGFloat tipsHeight = 40;
    CGFloat x = (screenWidth - tipsWidth) * 0.5;
    CGFloat y = (screenHeight - tipsHeight) * 0.5;
    
    CGRect tipsFrame = CGRectMake(x,y,tipsWidth,tipsHeight);
    tips.frame = tipsFrame;
    
    [self.view addSubview:tips];
}

#pragma mark 点击了删除按钮
- (void)isDeleteClick:(UIButton *)sender
{
    //点击了删除按钮
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除提示" message:@"确定要删除这枚收藏么？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"且慢" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"斩了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSUInteger row = [[self.favoriteListTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]] row];
        [self deleteFavoriteImage:row];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteFavoriteImage:(NSUInteger) index
{
    //
    
    //获取需要删除的图片路径
    NSString *imagePath = [self.favoriteImagePathArray objectAtIndex:index];
    //删除文件
    if ([FileOperationHelper deleteFileFromSandboxByPath:imagePath]) {
        
        //删除成功，从路径列表中删除该路径
        [self.favoriteImagePathArray removeObjectAtIndex:index];
        //从图片列表中删除该图片
        [self.favoriteImageArray removeObjectAtIndex:index];
        //刷新列表
        [self.favoriteListTableView reloadData];
    }
}

#pragma mark - UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favoriteImageArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:favoriteCell forIndexPath:indexPath];
    
    //解决tableview cell重用导致显示数据出错问题
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCell];
    }
    
    //图片
    UIImageView *favoriteImageView = [cell viewWithTag:1];
    favoriteImageView.image = self.favoriteImageArray[indexPath.row];
    
    //删除按钮
    UIButton *deleteButton = [cell viewWithTag:2];
    [deleteButton addTarget:self action:@selector(isDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIImage *image = self.favoriteImageArray[indexPath.row];
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    
    //ImageView的宽度
    CGFloat imageViewWidth = tableView.frame.size.width - 40;
    //计算imageView的高度
    CGFloat imageViewHeight = imageViewWidth * (imageHeight/imageWidth);
    
    return imageViewHeight + 90;

}

@end
