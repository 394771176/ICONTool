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

@end

NS_ASSUME_NONNULL_END
