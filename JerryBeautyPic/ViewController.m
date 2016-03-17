//
//  ViewController.m
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/13.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#import "ViewController.h"

#define tableViewCell @"tableCell"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

//列表
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong,nonatomic) NSMutableArray *imageDataArray;

@property (assign,nonatomic) CGRect screenRect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //加载初始数据
    [self initLoadImageData];
    //初始化变量
    [self viewSetup];
    
}

#pragma mark - 初始化界面及变量
- (void)viewSetup
{
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    self.screenRect = [[UIScreen mainScreen] bounds];
}

#pragma mark - 加载数据
#pragma mark 加载初始数据
- (void)initLoadImageData
{
    self.imageDataArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 2; i++) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ww1.sinaimg.cn/mw600/66b3de17gw1f0m57q8psyj20ci0gnaal.jpg"]]];
        [self.imageDataArray addObject:image];
    }
}

#pragma mark 异步加载图片调用
- (void)loadMoreImageInBackground
{
    NSLog(@"开始偷偷加载了 。。。 ");
    NSOperationQueue *operatinQueue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImage) object:nil];
    [operatinQueue addOperation:operation];
}

#pragma mark 加载图片
- (void)loadImage
{
    for (int i = 0; i < 3; i++) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://ww1.sinaimg.cn/mw600/66b3de17gw1f0m57q8psyj20ci0gnaal.jpg"]]];
        [self.imageDataArray addObject:image];
    }
    [self.myTableView reloadData];
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageDataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = [self.imageDataArray objectAtIndex:indexPath.row];
    CGSize imageSize = image.size;
    
    return imageSize.height + 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCell forIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:1];
    imageView.image = self.imageDataArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",(long)indexPath.row);
    if (indexPath.row == ([self.imageDataArray count]/2)) {
        [self loadMoreImageInBackground];
    }
}

@end
