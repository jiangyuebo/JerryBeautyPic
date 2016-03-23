//
//  ImageBlockModel.h
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/21.
//  Copyright © 2016年 Jerry. All rights reserved.
//
//列表条目对象

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageBlockModel : NSObject
//图片
@property (strong,nonatomic) UIImage *image;
//图片名称
@property (copy,nonatomic) NSString *imageName;
//说明
@property (copy,nonatomic) NSString *description;
//标签
@property (strong,nonatomic) NSMutableArray *tagsArray;
//发布日期 字符串
@property (strong,nonatomic) NSString *updateDateStr;
//发布日期
@property (strong,nonatomic) NSDate *updateDate;

@end
