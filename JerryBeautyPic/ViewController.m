//
//  ViewController.m
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/13.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+Hex.h"
#import "BigImageViewController.h"
#import "ImageBlockModel.h"
#import "InfoImageView.h"
#import "FavoritesListViewController.h"
#import "InternetTool.h"

#import "Header.h"

#import "AMTumblrHud.h"
#import "PishumToast.h"

#import "LoadingAnimation.h"

//下拉刷新
#import "MJRefresh.h"
//Bbom
#import <BmobSDK/Bmob.h>

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,NSURLSessionDataDelegate>

//列表
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong,nonatomic) NSMutableArray *imageBlockModelArray;

@property (assign,nonatomic) CGRect screenRect;

@property (assign,nonatomic) NSUInteger currentIndex;
//被选中的图片
@property (strong,nonatomic) UIImage *selectedImage;
//被选中的图片名称
@property (strong,nonatomic) NSString *selectedImageName;

//缓存
@property (strong,nonatomic) NSCache *imageCache;

//@property (strong,nonatomic) AMTumblrHud *tumblrHUD;
//加载中动画
@property (strong,nonatomic) LoadingAnimation *loadingAnimation;

//进入收藏按钮
@property (strong,nonatomic) UIButton *enterFavorites;

@property (strong,nonatomic) NSURLSession *session;

//待下载图片个数
@property (nonatomic) NSUInteger downloadingCount;
//下拉开关
@property (nonatomic) BOOL dragFlag;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentIndex = 0;
    self.downloadingCount = 0;
    self.dragFlag = YES;
    
    //加载初始数据
    [self initLoadImageData];
    //初始化变量
    [self viewSetup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - 初始化界面及变量
- (void)viewSetup{
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    //去掉tableView上面的空白
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.screenRect = [[UIScreen mainScreen] bounds];
    
    //初始化缓存
    self.imageCache = [NSCache new];
    
    //添加收藏进入按钮
    [self addEnterFavoriteListButton];
    
    //添加回到顶部按钮
    [self addGoToListTopButton];
    
    //添加下拉刷新
    self.myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSLog(@"开始刷新");
        [self loadImageInfoFromServer:DIRECTION_UP];
        //向前查询最新图片
        [self.myTableView.mj_header endRefreshing];
    }];
    
    //self.myTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreImageInBackground)];
    self.myTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        NSLog(@"开始上拉刷新");
        [self loadMoreImageInBackground];
    }];
    
}

#pragma mark 添加收藏进入按钮
- (void)addEnterFavoriteListButton{
    
    self.enterFavorites = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enterFavorites setBackgroundImage:[UIImage imageNamed:@"folder_bookmark"] forState:UIControlStateNormal];
    self.enterFavorites.frame = CGRectMake(0, 0, 22, 22);
    [self.enterFavorites addTarget:self action:@selector(enterFavoritesList) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.enterFavorites];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark 添加回到列表顶部按钮
- (void)addGoToListTopButton
{
    UIButton *topButton = [[UIButton alloc] init];
    [topButton setImage:[UIImage imageNamed:@"top"] forState:UIControlStateNormal];
    
    CGFloat buttonMargin = 10;
    CGFloat buttonWidth = 40;
    CGFloat buttonheight = 40;
    CGFloat x = self.screenRect.size.width - buttonWidth - buttonMargin;
    CGFloat y = self.screenRect.size.height - buttonheight - buttonMargin;
    CGRect topButtonFrame = CGRectMake(x,y, buttonWidth, buttonheight);
    topButton.frame = topButtonFrame;
    
    [topButton addTarget:self action:@selector(goToTop) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:topButton];
}

#pragma mark 进入收藏列表
- (void)enterFavoritesList
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FavoritesListViewController *fvtlvc = [storyboard instantiateViewControllerWithIdentifier:@"FavoritesListViewController"];
    [self.navigationController pushViewController:fvtlvc animated:YES];
}

#pragma mark 回到列表顶部
- (void)goToTop
{
    [self.myTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark 从服务器加载图片信息
- (void)loadImageInfoFromServer:(NSInteger) direction{
    
    if (self.dragFlag) {
        self.dragFlag = NO;
    }else{
        return;
    }
    
    BmobQuery *bombQuery = [BmobQuery queryWithClassName:@"picture"];
    bombQuery.limit = 3;
    if (direction == DIRECTION_UP) {
        //查询最新
        bombQuery.skip = 0;
    }else{
        bombQuery.skip = [self.imageBlockModelArray count];
    }
    
    [bombQuery orderByDescending:@"createdAt"];
    [bombQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if ([array count] > 0) {
            if (direction == DIRECTION_UP) {
                [self.imageBlockModelArray removeAllObjects];
            }
            
            //待下载图片个数
            self.downloadingCount = [array count];
            NSLog(@"待下载个数为 ： %lu",(unsigned long)self.downloadingCount);
            
            for (BmobObject *obj in array) {
                
                //
                ImageBlockModel *imageBlock = [[ImageBlockModel alloc] init];
                
                //获取图片ID
                NSString *imageId = [obj objectForKey:@"objectId"];
                
                //获得图片
                NSString *urlTemp = [obj objectForKey:@"urlstring"];
                NSString *imageURLStr = [urlTemp stringByRemovingPercentEncoding];
                
                //获得图片名
                NSString *imageName = [imageURLStr lastPathComponent];
                imageBlock.imageName = imageName;
                
                //读取图片数据
                //判断图片缓存中是否有该图片
                UIImage *image;
                if ([self.imageCache objectForKey:imageId]) {
                    //有，使用缓存中图片
                    NSLog(@"有缓存 ...");
                    image = [self.imageCache objectForKey:imageId];
                    imageBlock.image = image;
                    
                    self.downloadingCount--;
                }else{
                    //没有，从网络获取
                    //image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLStr]]];
                    //存入缓存
                    //[self.imageCache setObject:image forKey:imageId];
                    //网络下载图片
                    [self downloadImageInModel:imageBlock ById:imageId FromServer:imageURLStr];
                }
                //imageBlock.image = image;
                
                //获取更新时间
                NSString *updateDateStr = [obj objectForKey:@"createdAt"];
                updateDateStr = [updateDateStr substringWithRange:NSMakeRange(0, 10)];
                imageBlock.updateDateStr = updateDateStr;
                
                NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
                //获取tag
                NSString *tag1Str = [obj objectForKey:@"tag1"];
                if (tag1Str != NULL) {
                    [tagsArray addObject:tag1Str];
                }
                NSString *tag2Str = [obj objectForKey:@"tag2"];
                if (tag2Str != NULL) {
                    [tagsArray addObject:tag2Str];
                }
                NSString *tag3Str = [obj objectForKey:@"tag3"];
                if (tag3Str != NULL) {
                    [tagsArray addObject:tag3Str];
                }
                imageBlock.tagsArray = tagsArray;
                
                [self.imageBlockModelArray addObject:imageBlock];
            }
            
            if (self.downloadingCount == 0) {
                if (self.myTableView) {
                    [self.myTableView.mj_footer endRefreshing];
                    [self.myTableView reloadData];
                }
                
                if (self.loadingAnimation) {
                    [self.loadingAnimation stopLoadingaAnimation];
                }
                
                self.dragFlag = YES;
            }
        }else{
            [PishumToast showToastWithMessage:@"没有更多了~" Length:TOAST_MIDDLE ParentView:self.view];
            [self.loadingAnimation stopLoadingaAnimation];
        }
    }];
}

#pragma mark 加载初始数据
- (void)initLoadImageData
{
    //判断当前网络是否可用
    if ([InternetTool isNetConnected]) {
        //有网络连接
        self.imageBlockModelArray = [[NSMutableArray alloc] init];
//        //显示网络加载动画
//        self.tumblrHUD = [[AMTumblrHud alloc] initWithFrame:CGRectMake((CGFloat) ((self.view.frame.size.width - 55) * 0.5),
//                                                                       (CGFloat) ((self.view.frame.size.height - 20) * 0.5), 55, 20)];
//        self.tumblrHUD.hudColor = UIColorFromRGB(0xF1F2F3);//[UIColor magentaColor];
//        [self.view addSubview:self.tumblrHUD];
//        
//        [self.tumblrHUD showAnimated:YES];
        
        self.loadingAnimation = [[LoadingAnimation alloc] init];
        [self.loadingAnimation startLoadingAnimationInView:self.view];
        
        [self loadImageInfoFromServer:DIRECTION_DOWN];
    }else{
        //无网络连接
        [PishumToast showToastWithMessage:@"网络不给力，请检查网络设置" Length:3 ParentView:self.view];
    }
}

#pragma mark 异步加载图片调用
- (void)loadMoreImageInBackground
{
    NSLog(@"上拉加载 ...");
    NSOperationQueue *operatinQueue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImage) object:nil];
    [operatinQueue addOperation:operation];
}

#pragma mark 加载图片
- (void)loadImage
{
    [self loadImageInfoFromServer:DIRECTION_DOWN];
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageBlockModelArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageBlockModel *model = (ImageBlockModel *)[self.imageBlockModelArray objectAtIndex:indexPath.row];
    UIImage *image = model.image;
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    
    //ImageView的宽度
    CGFloat imageViewWidth = tableView.frame.size.width - 40;
    //计算imageView的高度
    CGFloat imageViewHeight = imageViewWidth * (imageHeight/imageWidth);

    return imageViewHeight + 90;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCell forIndexPath:indexPath];
    
    //解决tableview cell重用导致显示数据出错问题
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCell];
    }
    else{
        //删除数据出错的子视图(动态添加的tag视图)
        UIView *tagsView = [cell viewWithTag:4];
        while ([tagsView.subviews lastObject] != nil) {
            [[tagsView.subviews lastObject] removeFromSuperview];
        }
    }
    
    InfoImageView *imageView = [cell viewWithTag:1];
    
    ImageBlockModel *imageBlock = self.imageBlockModelArray[indexPath.row];
    
    imageView.image = imageBlock.image;
    imageView.imageName = imageBlock.imageName;
    
    //图片添加点击事件
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked:)];
    [imageView addGestureRecognizer:tapGestureRecognizer];
    imageView.userInteractionEnabled = YES;
    
    //设置图片下方区域
    UIView *subTitleView = [cell viewWithTag:2];
    subTitleView.layer.borderWidth = 1;
    subTitleView.layer.borderColor = [[UIColor colorWithHexString:@"#d6dbec"] CGColor];//线的颜色
    
    //更新日期
    UILabel *updateDate = [cell viewWithTag:3];
    updateDate.text = imageBlock.updateDateStr;
    
    //tag
    UIView *tagsView = [cell viewWithTag:4];
    CGFloat tagWidth = 60;
    if ([imageBlock.tagsArray count] > 0) {
        for (int i = 0; i < [imageBlock.tagsArray count]; i ++) {
            //tag 图片
            UIImage *tagImage = [UIImage imageNamed:@"tag"];
            UIImageView *tagImageView = [[UIImageView alloc] initWithImage:tagImage];
            CGRect tagImageFrame = CGRectMake(5 + (i * tagWidth), 15, 20, 20);
            tagImageView.frame = tagImageFrame;
            
            //tag 文字
            NSString *tagOrigin = imageBlock.tagsArray[i];
            NSString *tagContent = nil;
            if ([tagOrigin isEqualToString:TAG_BEAUTY]) {
                tagContent = @"美女";
            }else if ([tagOrigin isEqualToString:TAG_LEG]){
                tagContent = @"美腿";
            }else if ([tagOrigin isEqualToString:TAG_SWIM_SUIT]){
                tagContent = @"泳衣";
            }else if ([tagOrigin isEqualToString:TAG_TIGHT]){
                tagContent = @"紧身";
            }else if ([tagOrigin isEqualToString:TAG_ASS]){
                tagContent = @"美臀";
            }else if ([tagOrigin isEqualToString:TAG_SPORT]){
                tagContent = @"运动";
            }
            
            UILabel *tagLabel = [[UILabel alloc] init];
            tagLabel.text = tagContent;
            [tagLabel setTextColor:[UIColor grayColor]];
            CGRect tagLabelFrame = CGRectMake(tagImageFrame.origin.x + tagImageFrame.size.width,15, 40, 20);
            tagLabel.frame = tagLabelFrame;
            
            [tagsView addSubview:tagImageView];
            [tagsView addSubview:tagLabel];
        }
    }
    
    return cell;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
    //设置当前显示的是倒数第几张图片时，开始从后台加载新图片
//    if (([self.imageBlockModelArray count] - indexPath.row) < leftPicNumber) {
//        [self loadMoreImageInBackground];
//    }
//}

#pragma mark - 点击事件
- (void)imageClicked:(UITapGestureRecognizer *) gestureRecognizer
{
    //图片被点击
    InfoImageView *imageView = (InfoImageView *)gestureRecognizer.view;
    self.selectedImage = imageView.image;
    self.selectedImageName = imageView.imageName;
    
    //跳转到大图页面
    [self performSegueWithIdentifier:@"showBig" sender:self];
}

#pragma mark - 跳转处理
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //判断所选图片在数组中的位置
    BigImageViewController *bigImageViewController = segue.destinationViewController;
    bigImageViewController.image = self.selectedImage;
    bigImageViewController.imageName = self.selectedImageName;
}

#pragma mark - 下载图片
- (void)downloadImageInModel:(ImageBlockModel *) mode ById:(NSString *) imageId FromServer:(NSString *) urlStr{
    if (urlStr) {
        //创建URL
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            self.downloadingCount--;
            NSLog(@"待下载图片个数：%lu",(unsigned long)self.downloadingCount);
            
            UIImage *image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:location]] copy];
            [self.imageCache setObject:image forKey:imageId];
            
            mode.image = image;
            
            //如果全部下载完成，刷新
            if (self.downloadingCount == 0) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (self.myTableView) {
                        [self.myTableView.mj_footer endRefreshing];
                        [self.myTableView reloadData];
                    }
                    
                    if (self.loadingAnimation) {
                        [self.loadingAnimation stopLoadingaAnimation];
                    }
                    
                    self.dragFlag = YES;
                });
            }
        }];
        
        [task resume];
    }
}

@end
