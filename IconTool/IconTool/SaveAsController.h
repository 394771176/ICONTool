//
//  SaveAsController.h
//  IconTool
//
//  Created by cheng on 2020/11/16.
//  Copyright © 2020 wangzhicheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class SaveAsController;

@protocol SaveAsControllerDelegate <NSObject>

@optional
- (void)SaveAsControllerDidSubmitAction:(SaveAsController *)vc withName:(NSString *)name;

@end

@interface SaveAsController : NSViewController

@property (nonatomic, weak) id<SaveAsControllerDelegate> delegate;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) NSInteger type;//0 另存为， 1保存替换原文件

@end

NS_ASSUME_NONNULL_END
