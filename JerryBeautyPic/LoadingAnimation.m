//
//  LoadingAnimation.m
//  JerryBeautyPic
//
//  Created by Jerry on 16/4/21.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#import "LoadingAnimation.h"
#import "AMTumblrHud.h"

#import "Header.h"

@interface LoadingAnimation()

@property (strong,nonatomic) AMTumblrHud *tumblrHUD;

@end

@implementation LoadingAnimation

- (void)startLoadingAnimationInView:(UIView *)view
{
    //多线程处理
    [NSThread detachNewThreadSelector:@selector(showLoadingAnimation:) toTarget:self withObject:view];
}

- (void)showLoadingAnimation:(UIView *) view
{
    self.tumblrHUD = [[AMTumblrHud alloc] initWithFrame:CGRectMake((CGFloat) ((view.frame.size.width - 55) * 0.5),
                                                                   (CGFloat) ((view.frame.size.height - 20) * 0.5), 55, 20)];
    
    self.tumblrHUD.hudColor = UIColorFromRGB(0xF1F2F3);//[UIColor magentaColor];
    [view addSubview:self.tumblrHUD];
    [self.tumblrHUD showAnimated:YES];
}

- (void)stopLoadingaAnimation
{
    [self.tumblrHUD removeFromSuperview];
}

@end
