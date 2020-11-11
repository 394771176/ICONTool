//
//  DTFileManager.m
//  Snake
//
//  Created by cheng on 17/8/19.
//  Copyright © 2017年 cheng. All rights reserved.
//

#import "DTFileManager.h"

BOOL FFCreateFolderIfNeeded(NSString *dirPath) {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager new];
    if (![fileManager fileExistsAtPath:dirPath]) {
        if (![fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Unable to create folder at %@: %@", dirPath, error.localizedDescription);
            return NO;
        }
    }
    return YES;
}

@interface DTFileManager () {
    
}

@property (nonatomic, readonly) NSFileManager *fileManager;

@end

@implementation DTFileManager

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSFileManager *)fileManager
{
    return [NSFileManager defaultManager];
}

+ (NSFileManager *)fileManager
{
    return [[self sharedInstance] fileManager];
}

+ (BOOL)isFileExist:(NSString *)path
{
    return [[self fileManager] fileExistsAtPath:path];
}

+ (BOOL)isFileDirectory:(NSString *)path
{
    BOOL isDir = NO;
    BOOL isExist = NO;
    isExist = [[self fileManager] fileExistsAtPath:path isDirectory:&isDir];
    return isExist & isDir;
}

+ (NSString *)fileNameFromPath:(NSString *)path
{
    if (path.length) {
        return [[[path lastPathComponent] componentsSeparatedByString:@"."] firstObject];
    }
    return nil;
}

+ (NSArray *)contentsWithPath:(NSString *)path
{
    return [[self fileManager] contentsOfDirectoryAtPath:path error:NULL];
}

+ (NSArray *)validContentsWithPath:(NSString *)path
{
    NSArray *array = [self contentsWithPath:path];
    if (array.count && [array containsObject:@".DS_Store"]) {
        NSMutableArray *mArr = array.mutableCopy;
        [mArr removeObject:@".DS_Store"];
        return mArr;
    } else {
        return array;
    }
}

+ (NSArray *)subpathsWithPath:(NSString *)path
{
    return [[self fileManager] subpathsOfDirectoryAtPath:path error:NULL];
}

+ (NSArray *)subpathsAtPath:(NSString *)path
{
    return [[self fileManager] subpathsAtPath:path];
}

+ (BOOL)copyItemWithPath:(NSString *)path toPath:(NSString *)toPath
{
    return [self copyItemWithPath:path toPath:toPath cover:YES];
}

+ (BOOL)copyItemWithPath:(NSString *)path toPath:(NSString *)toPath cover:(BOOL)cover
{
    if ([self.fileManager fileExistsAtPath:path]) {
        BOOL exit = [self.fileManager fileExistsAtPath:toPath];
        if (cover || !exit) {
            if (exit) {
                [self.fileManager removeItemAtPath:toPath error:NULL];
            }
            NSError *error = nil;
            [self.fileManager copyItemAtPath:path toPath:toPath error:&error];
            return error ? NO : YES;
        }
    }
    return NO;
}

+ (BOOL)moveItemWithPath:(NSString *)path toPath:(NSString *)toPath
{
    return [self moveItemWithPath:path toPath:toPath cover:YES];
}

+ (BOOL)moveItemWithPath:(NSString *)path toPath:(NSString *)toPath cover:(BOOL)cover
{
    if ([self.fileManager fileExistsAtPath:path]) {
        if (cover || ![self.fileManager fileExistsAtPath:toPath]) {
            NSError *error = nil;
            [self.fileManager moveItemAtPath:path toPath:toPath error:&error];
            return error ? NO : YES;
        }
    }
    return NO;
}

+ (BOOL)deleteItemWithPath:(NSString *)path
{
    if (path) {
        NSError *error = nil;
        [[self fileManager] removeItemAtPath:path error:&error];
        return error ? NO : YES;
    }
    return NO;
}

+ (BOOL)deleteItemWithPath:(NSString *)path fileName:(NSString *)fileName
{
    if (path && fileName) {
     return [self deleteItemWithPath:[path stringByAppendingPathComponent:fileName]];
    }
    return NO;
}


+ (NSString *)pathFromPath:(NSString *)path dirName:(NSString *)dir suffix:(NSString *)suffix
{
    NSString *toPath = [path stringByDeletingLastPathComponent];
    return [self pathFromPath:path toPath:toPath dirName:dir suffix:suffix];
}

+ (NSString *)pathFromPath:(NSString *)path toPath:(NSString *)toPath dirName:(NSString *)dir suffix:(NSString *)suffix
{
    if (!path.length) {
        return nil;
    }
    NSString *name = path.lastPathComponent;
    if (suffix && [name rangeOfString:[NSString stringWithFormat:@"_%@.", suffix]].length <= 0) {
        if ([name rangeOfString:@"."].length) {
            name = [name stringByReplacingOccurrencesOfString:@"." withString:[NSString stringWithFormat:@"_%@.", suffix]];
        } else {
            name = [name stringByAppendingFormat:@"_%@", suffix];
        }
    }
    
    NSString *result = nil;
    if (toPath.length) {
        result = toPath;
    } else if (path.length) {
        result = [path stringByDeletingLastPathComponent];
    }
    if (result.length && dir.length) {
        result = [toPath stringByAppendingPathComponent:dir];
    }
    FFCreateFolderIfNeeded(result);
    
    return [result stringByAppendingPathComponent:name];
}

@end
