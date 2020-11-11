//
//  DTFileManager.h
//  Snake
//
//  Created by cheng on 17/8/19.
//  Copyright © 2017年 cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HOME_PATH           (NSHomeDirectory())
#define DOC_PATH            ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject])
#define DOCPATH(name)       ([DOC_PATH stringByAppendingPathComponent:name])

#define PATH_DIR    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define PATH_DESKTOP    [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) firstObject]
#define PATH_DESKTOPAPP         ([PATH_DESKTOP stringByAppendingPathComponent:APP_DISPLAY_NAME])
#define PATH(name)      [PATH_DIR stringByAppendingPathComponent:name]
#define DESKTOP(name)   [PATH_DESKTOP stringByAppendingPathComponent:name]
#define DESKTOP_APP(name)   ([[PATH_DESKTOP stringByAppendingPathComponent:APP_DISPLAY_NAME] stringByAppendingPathComponent:name])

extern BOOL FFCreateFolderIfNeeded(NSString *dirPath);

@interface DTFileManager : NSObject

// 宏 path
//+ (NSString *)homePath;
//+ (NSString *)docPath;

+ (BOOL)isFileExist:(NSString *)path;
+ (BOOL)isFileDirectory:(NSString *)path;

+ (NSString *)fileNameFromPath:(NSString *)path;

// file name array
+ (NSArray *)contentsWithPath:(NSString *)path;
+ (NSArray *)validContentsWithPath:(NSString *)path;

// sub path array
+ (NSArray *)subpathsWithPath:(NSString *)path;

+ (NSArray *)subpathsAtPath:(NSString *)path;

// 复制 删除

+ (BOOL)copyItemWithPath:(NSString *)path toPath:(NSString *)toPath;//默认覆盖
+ (BOOL)copyItemWithPath:(NSString *)path toPath:(NSString *)toPath cover:(BOOL)cover;

+ (BOOL)moveItemWithPath:(NSString *)path toPath:(NSString *)toPath;//默认覆盖
+ (BOOL)moveItemWithPath:(NSString *)path toPath:(NSString *)toPath cover:(BOOL)cover;

+ (BOOL)deleteItemWithPath:(NSString *)path;
+ (BOOL)deleteItemWithPath:(NSString *)path fileName:(NSString *)fileName;

//拷贝文件到当前目录下，并创建单独文件夹dir，同时添加后缀标识suffix
+ (NSString *)pathFromPath:(NSString *)path dirName:(NSString *)dir suffix:(NSString *)suffix;
+ (NSString *)pathFromPath:(NSString *)path toPath:(NSString *)toPath dirName:(NSString *)dir suffix:(NSString *)suffix;

@end
