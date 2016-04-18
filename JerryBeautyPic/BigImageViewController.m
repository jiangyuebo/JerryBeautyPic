//
//  BigImageViewController.m
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/21.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#import "BigImageViewController.h"
#import "FileOperationHelper.h"
#import "PishumToast.h"
#import "Header.h"

@interface BigImageViewController ()<UIScrollViewDelegate>

@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UIScrollView *bigImageScrollView;

@property (assign,nonatomic) CGRect screenRect;

@property (assign,nonatomic) CGRect originFrame;

//下载按钮
@property (strong,nonatomic) UIButton *downloadButton;

//收藏按钮
@property (strong,nonatomic) UIButton *favoriteButton;

@end

@implementation BigImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenRect = [[UIScreen mainScreen] bounds];
    
    [self resetImageViewSize];
    
    [self initView];
}

#pragma mark 初始化界面控件
- (void)initView
{
    //添加下载按钮
    [self addControlView];
    
    //判断当前图片是否已在收藏中
    if (![self isImageInFavorites:self.imageName]) {
        //图片未收藏，添加收藏按钮
        [self addFavoriteButton];
    }
}

#pragma mark 添加收藏按钮
- (void)addFavoriteButton
{
    self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.favoriteButton setBackgroundImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    self.favoriteButton.frame = CGRectMake(0, 0, 22, 22);
    [self.favoriteButton addTarget:self action:@selector(favoriteClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.favoriteButton];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark 隐藏收藏按钮
- (void)removeFavoriteButton
{
    if (self.favoriteButton) {
        self.favoriteButton.hidden = YES;
    }
}

#pragma mark delegate view did appear
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //显示按钮出现动画
    
    [self downLoadButtonMove:DIRECTION_UP withView:self.downloadButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self downLoadButtonMove:DIRECTION_DOWN withView:self.downloadButton];
}

#pragma mark 点击了下载按钮
- (void)downloadImage{
    [self downLoadButtonMove:DIRECTION_DOWN withView:self.downloadButton];
    //将图片下载到本地相册
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

#pragma mark 点击了收藏按钮
- (void)favoriteClicked:(UIBarButtonItem *)sender
{
    //获取图片存储文件夹路径
    NSString *savePath = [FileOperationHelper getPictureSaveDocumentPath:DIR_NAME_IMAGES];
    //判断文件夹是否存在
    if ([FileOperationHelper isDocumentExistAtPath:savePath]) {
        //文件夹存在，判断收藏数量
        NSArray *fileNameArray = [FileOperationHelper getAllFileNameInDocumentByDocumentName:DIR_NAME_IMAGES];
        if ([fileNameArray count] < MAC_FAVORITE) {
            //还可以收藏
            [self saveImageToSandBox:self.image];
        }else{
            //提示
            [PishumToast showToastWithMessage:@"暂时只可以收藏10张哦~" Length:TOAST_SHORT ParentView:self.view];
        }
    }else{
        //文件夹不存在，收藏
        [self saveImageToSandBox:self.image];
    }
}

#pragma mark 保存到沙盒中
- (void)saveImageToSandBox:(UIImage *)image
{
    //获取图片存储文件夹路径
    NSString *savePath = [FileOperationHelper getPictureSaveDocumentPath:DIR_NAME_IMAGES];
    //判断指定文件夹是否存在
    if ([FileOperationHelper isDocumentExistAtPath:savePath]) {
        //
        [self saveImage:image];
    }else{
        //创建文件夹
        if ([FileOperationHelper createDocumentInSandBoxByDocumentName:DIR_NAME_IMAGES]) {
            [self saveImage:image];
        }else{
            [PishumToast showToastWithMessage:@"文件夹创建失败，无法保存图片" Length:TOAST_SHORT ParentView:self.view];
        }
    }
    
}

#pragma mark 保存图片
- (BOOL)saveImage:(UIImage *)image
{
    //获取图片保存路径
    NSString *imagePath = [FileOperationHelper getPictureSavePathByDocumentName:DIR_NAME_IMAGES andImageName:self.imageName];
    if ([FileOperationHelper saveImage:image toSandboxByPath:imagePath]) {
        //保存成功
        [PishumToast showToastWithMessage:@"收藏成功" Length:TOAST_SHORT ParentView:self.view];
        //隐藏收藏按钮
        [self removeFavoriteButton];
        return YES;
    }else{
        //保存失败
        [PishumToast showToastWithMessage:@"收藏失败" Length:TOAST_SHORT ParentView:self.view];
        return NO;
    }
}

#pragma mark 判断当前照片是否已在收藏中
- (BOOL)isImageInFavorites:(NSString *)imageName
{
    NSString *savePath = [FileOperationHelper getPictureSavePathByDocumentName:DIR_NAME_IMAGES andImageName:imageName];
    if ([FileOperationHelper isDocumentExistAtPath:savePath]) {
        return YES;
    }
    return NO;
}


#pragma mark 保存至相册的回调
- (void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo
{
    NSString *msg = nil;
    if (error != NULL) {
        msg = @"保存失败";
        [PishumToast showToastWithMessage:msg Length:TOAST_SHORT ParentView:self.view];
        
        //再次显示下载按钮
        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(showButton) userInfo:nil repeats:NO];
    }else{
        msg = @"保存成功";
        [PishumToast showToastWithMessage:msg Length:TOAST_SHORT ParentView:self.view];
    }
}

#pragma mark 再次显示下载按钮
- (void)showButton
{
    [self downLoadButtonMove:DIRECTION_UP withView:self.downloadButton];
}


#pragma mark 根据图片大小重设imageView大小和位置
- (void)resetImageViewSize
{
    self.automaticallyAdjustsScrollViewInsets = false;
    
    //图片尺寸
    CGSize imageSize = self.image.size;
    
    //屏幕宽高
    CGFloat screenWidth = self.screenRect.size.width;
//    CGFloat screenHeight = self.screenRect.size.height;
    
    //调整后图片宽高
    CGFloat imageViewWidth = screenWidth;
    CGFloat imageViewHeight = screenWidth * (imageSize.height/imageSize.width);
    CGFloat imageViewX = 0;
    CGFloat imageViewY = 80;
    
    //调整imageView宽高
    CGRect imageViewNewRect = CGRectMake(imageViewX, imageViewY, imageViewWidth, imageViewHeight);
    //保存原始大小
    self.originFrame = imageViewNewRect;
    
    //添加图片
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.frame = imageViewNewRect;
//    self.imageView.userInteractionEnabled = YES;
    
    //为图片添加手势
//    [self addGestureRecognizerToView:self.imageView];
    
    //创建ScrollView,将ImageView放入图片尺寸的scrollview中，方便的使用手势及缩放
    self.bigImageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.bigImageScrollView.contentSize = CGSizeMake(imageViewWidth, imageViewHeight);
//    self.bigImageScrollView.contentSize = self.image.size;
    self.bigImageScrollView.userInteractionEnabled = YES;
    self.bigImageScrollView.delegate = self;
    [self.bigImageScrollView addSubview:self.imageView];
    
    [self.view addSubview:self.bigImageScrollView];
    
    //设置最大伸缩比
    self.bigImageScrollView.maximumZoomScale = 2.0;
    self.bigImageScrollView.minimumZoomScale = 1.0;
    
    //双击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.bigImageScrollView addGestureRecognizer:tapGesture];
}

- (void)doubleTap:(UITapGestureRecognizer *) sender
{
    //判断当前是否放大
    if (self.bigImageScrollView.zoomScale > 1) {
        //当前放大了，缩小
        [self.bigImageScrollView setZoomScale:1.0 animated:YES];
    }else if (self.bigImageScrollView.zoomScale == 1){
        //当前没放大，放大
        [self.bigImageScrollView setZoomScale:2.0 animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 添加界面元素
- (void)addControlView
{
    self.downloadButton = [[UIButton alloc] init];
    [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"share_edit_download_n"] forState:UIControlStateNormal];
    [self.downloadButton addTarget:self action:@selector(downloadImage) forControlEvents:UIControlEventTouchUpInside];
    
    self.downloadButton.layer.cornerRadius = 10;
    self.downloadButton.layer.zPosition = 1;
    
    CGFloat buttonWidth = 190;
    CGFloat buttonHeight = 58;
    
    CGFloat x = (self.screenRect.size.width - buttonWidth)/2;
    CGFloat y = self.screenRect.size.height;
    CGRect originFrame = CGRectMake(x, y, buttonWidth, buttonHeight);
    self.downloadButton.frame = originFrame;
    [self.view addSubview:self.downloadButton];
}

#pragma mark 下载按钮动画
- (void)downLoadButtonMove:(NSInteger) direction withView:(UIView *)view
{
    int directionPlus = 0;
    if (direction == 0) {
        //向上
        directionPlus = -78;
    }else{
        //向下
        directionPlus = +78;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //目的地
    CGRect rect = CGRectMake(view.frame.origin.x, view.frame.origin.y + directionPlus, view.frame.size.width, view.frame.size.height);
    view.frame = rect;
    [UIView commitAnimations];
}

#pragma mark - 手势相关
#pragma mark 添加手势
- (void)addGestureRecognizerToView:(UIView *)view
{
    //添加缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    //添加移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
}

#pragma mark 处理缩放手势
- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        
        //限制最小尺寸
//        if (self.imageView.frame.size.width < self.originFrame.size.width) {
//            self.imageView.frame = self.originFrame;
//        }
        
        pinchGestureRecognizer.scale = 1;
    }
}

#pragma mark 处理移动手势
- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x,view.center.y + translation.y}];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIScrollView Delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
