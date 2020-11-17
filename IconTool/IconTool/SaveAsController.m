//
//  SaveAsController.m
//  IconTool
//
//  Created by cheng on 2020/11/16.
//  Copyright © 2020 wangzhicheng. All rights reserved.
//

#import "SaveAsController.h"
#import "DTFileManager.h"

@interface SaveAsController () {
    
    IBOutlet NSTextField *titleLabel;
    IBOutlet NSTextField *nameTextField;
}

@end

@implementation SaveAsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    if (_type == 1) {
        titleLabel.stringValue = @"保存：";
    }
    
    NSString *string = [DTFileManager fileNameFromPath:self.filePath];
    if (string.length) {
        nameTextField.stringValue = string;
        if ([nameTextField respondsToSelector:@selector(selectAll:)]) {
            [nameTextField performSelector:@selector(selectAll:) withObject:nil afterDelay:.1f];
        } else {
            nameTextField.accessibilitySelectedTextRange = NSMakeRange(0, string.length);
        }
    }
}

- (IBAction)submitAction:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(SaveAsControllerDidSubmitAction:withName:)]) {
        [_delegate SaveAsControllerDidSubmitAction:self withName:nameTextField.stringValue];
    }
    [self dismissViewController:self];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewController:self];
}

@end
