//
//  IconTextEditController.h
//  IconTool
//
//  Created by cheng on 2020/11/13.
//  Copyright © 2020 wangzhicheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IconTextEditController;

@protocol IconTextEditControllerDelegate <NSObject>

@optional
- (void)IconTextEditControllerDidFinish:(IconTextEditController *)vc;

@end

@interface IconTextEditController : NSViewController

@property (nonatomic, weak) id<IconTextEditControllerDelegate> delegate;

@property (nonatomic, strong) NSString *filePath;

@end
