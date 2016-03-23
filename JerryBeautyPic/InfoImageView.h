//
//  InfoImageView.h
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/23.
//  Copyright © 2016年 Jerry. All rights reserved.
//
//为了将图片名称存储在UIImageView中，以便点击事件传递的VIEW参数中能取得图片名称

#import <UIKit/UIKit.h>

@interface InfoImageView : UIImageView

@property (strong,nonatomic) NSString *imageName;

@end
