//
//  FileOperationHelper.h
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/23.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileOperationHelper : UITextField

//获取图片存储文件夹
+ (NSString *)getPictureSaveDocumentPath:(NSString *)documentName;

//获取图片存储路径
+ (NSString *)getPictureSavePathByDocumentName:(NSString *)documentName andImageName:(NSString *)imageName;

//获取沙盒路径
+ (NSString *)getSandBoxDirectory;

//在沙盒下创建文件夹
+ (BOOL)createDocumentInSandBoxByDocumentName:(NSString *)documentName;

//判断 文件夹/文件 是否存在
+ (BOOL)isDocumentExistAtPath:(NSString *)path;

//保存图片到沙盒指定路径下
+ (BOOL)saveImage:(UIImage *)image toSandboxByPath:(NSString *)path;

//删除沙盒中指定路径文件
+ (BOOL)deleteFileFromSandboxByPath:(NSString *)path;

//获取沙盒路径下所有文件名
+ (NSArray *)getAllFileNameInDocumentByDocumentName:(NSString *)documentPath;

//去掉文件名后缀名
+ (NSString *)deleteFileNameExtension:(NSString *)fileName;

@end
