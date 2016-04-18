//
//  FileOperationHelper.m
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/23.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#import "FileOperationHelper.h"

@implementation FileOperationHelper

+ (NSString *)getPictureSaveDocumentPath:(NSString *)documentName
{
    NSString *sandboxPath = [self getSandBoxDirectory];
    NSString *myDocumentFilePath = [sandboxPath stringByAppendingPathComponent:documentName];
    return myDocumentFilePath;
}

+ (NSString *)getPictureSavePathByDocumentName:(NSString *)documentName andImageName:(NSString *)imageName
{
    NSString *documentPath = [self getPictureSaveDocumentPath:documentName];
    NSString *temp = [NSString stringWithFormat:@"/%@",imageName];
    NSString *imagePath = [documentPath stringByAppendingString:temp];
    return imagePath;
}

+ (NSString *)getSandBoxDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (BOOL)createDocumentInSandBoxByDocumentName:(NSString *)documentName
{
    NSString *sandboxPath = [self getSandBoxDirectory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建文件夹路径
    if (documentName) {
        NSString *myDocumentFilePath = [sandboxPath stringByAppendingPathComponent:documentName];
        
        NSError *error;
        BOOL isCreated = [fileManager createDirectoryAtPath:myDocumentFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"create Document error : %@",error.localizedDescription);
        }
        
        return isCreated;
    }else{
        return NO;
    }
}

+ (BOOL)isDocumentExistAtPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:path];
}

+ (BOOL)saveImage:(UIImage *)image toSandboxByPath:(NSString *)path
{
    if (!image || !path) {
        return NO;
    }
    //UIImage -> NSData
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager createFileAtPath:path contents:imageData attributes:nil];
}

+ (NSArray *)getAllFileNameInDocumentByDocumentName:(NSString *)documentName
{
    NSString *path = [self getPictureSaveDocumentPath:documentName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    return [fileManager subpathsOfDirectoryAtPath:path error:nil];
}

+ (NSString *)deleteFileNameExtension:(NSString *)fileName
{
    NSRange range = [fileName rangeOfString:@"." options:NSBackwardsSearch];
    if (range.length > 0) {
        fileName = [fileName substringToIndex:NSMaxRange(range)-1];
    }
    
    return fileName;
}

#pragma mark 删除沙盒中指定路径文件
+ (BOOL)deleteFileFromSandboxByPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:path error:nil];
}
@end
