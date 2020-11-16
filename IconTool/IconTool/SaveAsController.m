//
//  SaveAsController.m
//  IconTool
//
//  Created by cheng on 2020/11/16.
//  Copyright © 2020 wangzhicheng. All rights reserved.
//

#import "SaveAsController.h"

@interface SaveAsController () {
    
    IBOutlet NSTextField *nameTextField;
}

@end

@implementation SaveAsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
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
