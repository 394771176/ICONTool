//
//  NSUserDataManager.m
//  QuestionCompareTools
//
//  Created by cheng on 2017/10/27.
//  Copyright © 2017年 cheng. All rights reserved.
//

#import "NSUserDataManager.h"

#define APP_CONST_KJZ_DB_PATH               @"app.const.kjz.db.path"
#define APP_CONST_OTHER_DB_PATH             @"app.const.other.db.path"
#define APP_CONST_OTHER_DB_TYPE             @"app.const.other.db.type"

#define APP_CONST_OTHER_CL_DB_PATH             @"app.const.other.cl.db.path"

@implementation NSUserDataManager

@synthesize kjzPath = _kjzPath;
@synthesize dbType = _dbType;
@synthesize otherCLPath = _otherCLPath;

+ (instancetype)sharedInstance
{
    static id instance = nil;
    if (!instance) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (void)setDbType:(NSInteger)dbType
{
    _dbType = dbType;
    [[NSUserDefaults standardUserDefaults] setInteger:dbType forKey:APP_CONST_OTHER_DB_TYPE];
}

- (NSInteger)dbType
{
    if (!_dbType) {
        _dbType = [[NSUserDefaults standardUserDefaults] integerForKey:APP_CONST_OTHER_DB_TYPE];
    }
    return _dbType;
}

- (NSString *)kjzPath
{
    if (!_kjzPath) {
        _kjzPath = [[NSUserDefaults standardUserDefaults] stringForKey:APP_CONST_KJZ_DB_PATH];
    }
    return _kjzPath;
}

- (void)setKjzPath:(NSString *)kjzPath
{
    _kjzPath = kjzPath;
    [[NSUserDefaults standardUserDefaults] setObject:kjzPath forKey:APP_CONST_KJZ_DB_PATH];
}

- (NSString *)otherCLPath
{
    if (!_otherCLPath) {
        _otherCLPath = [[NSUserDefaults standardUserDefaults] stringForKey:APP_CONST_OTHER_CL_DB_PATH];
    }
    return _otherCLPath;
}

- (void)setOtherCLPath:(NSString *)otherCLPath
{
    _otherCLPath = otherCLPath;
    [[NSUserDefaults standardUserDefaults] setObject:otherCLPath forKey:APP_CONST_OTHER_CL_DB_PATH];
}

- (NSString *)otherPathIsOld:(BOOL)isOld
{
    NSString *key = [APP_CONST_OTHER_DB_PATH stringByAppendingFormat:@"_%zd_%zd", (isOld ? 1 : 0), _dbType];
    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    return string;
}

- (void)setOtherPath:(NSString *)otherPath isOld:(BOOL)isOld
{
    NSString *key = [APP_CONST_OTHER_DB_PATH stringByAppendingFormat:@"_%zd_%zd", (isOld ? 1 : 0), _dbType];
    [[NSUserDefaults standardUserDefaults] setObject:otherPath forKey:key];
}

- (NSString *)otherPath
{
    return [self otherPathIsOld:NO];
}

- (NSString *)otherPathWithDbType:(NSInteger)type
{
    BOOL isOld = NO;
    NSString *key = [APP_CONST_OTHER_DB_PATH stringByAppendingFormat:@"_%zd_%zd", (isOld ? 1 : 0), type];
    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    return string;
}

- (void)setOtherPath:(NSString *)otherPath withDbType:(NSInteger)type
{
    BOOL isOld = NO;
    NSString *key = [APP_CONST_OTHER_DB_PATH stringByAppendingFormat:@"_%zd_%zd", (isOld ? 1 : 0), type];
    [[NSUserDefaults standardUserDefaults] setObject:otherPath forKey:key];
}

- (void)setOtherPath:(NSString *)otherPath
{
    [self setOtherPath:otherPath isOld:NO];
}

- (NSString *)otherOldPath
{
    return [self otherPathIsOld:YES];
}

- (void)setOtherOldPath:(NSString *)otherOldPath
{
    [self setOtherPath:otherOldPath isOld:YES];
}

- (void)setPath:(NSString *)path forKey:(NSString *)key
{
    if (key.length) {
        if (path.length) {
            [[NSUserDefaults standardUserDefaults] setObject:path forKey:key];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
    }
}

- (NSString *)pathForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

+ (void)setPathForTextField:(NSTextField *)textField withKey:(NSString *)key
{
    NSString *string = [[self sharedInstance] pathForKey:key];
    if (string.length) {
        textField.stringValue = string;
    }
}

+ (void)savePathFromTextField:(NSTextField *)textField withKey:(NSString *)key
{
    [self savePathFromTextField:textField withKey:key clean:NO];
}

+ (void)savePathFromTextField:(NSTextField *)textField withKey:(NSString *)key clean:(BOOL)clean
{
    NSString *string = textField.stringValue;
    if (string.length || clean) {
        [[self sharedInstance] setPath:string forKey:key];
    }
}


@end
