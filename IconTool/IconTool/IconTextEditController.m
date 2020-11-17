//
//  IconTextEditController.m
//  IconTool
//
//  Created by cheng on 2020/11/13.
//  Copyright © 2020 wangzhicheng. All rights reserved.
//

#import "IconTextEditController.h"
#import "SaveAsController.h"
#import "DTFileManager.h"

@interface IconTextEditController () <SaveAsControllerDelegate> {
    
    IBOutlet NSTextView *fileTextView;
    
    IBOutlet NSButton *deleteBtn;
}

@end

@implementation IconTextEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *text = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:NULL];
    if (text) {
        fileTextView.string = text;
    }
    
    NSString *dir = self.filePath.stringByDeletingLastPathComponent;
    if ([DTFileManager contentsWithPath:dir].count > 1) {
        deleteBtn.hidden = NO;
    } else {
        deleteBtn.hidden = YES;
    }
    NSLog(@"sub contents: %@", [DTFileManager contentsWithPath:dir]);
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewController:self];
}

- (void)didEditFinish
{
    if (_delegate && [_delegate respondsToSelector:@selector(IconTextEditControllerDidFinish:)]) {
        [_delegate IconTextEditControllerDidFinish:self];
    }
    [self dismissViewController:self];
}

- (IBAction)deleteAction:(id)sender
{
    NSString *toPath = self.filePath;
    if (toPath.length) {
        [DTFileManager deleteItemWithPath:toPath];
    }
    [self didEditFinish];
}

- (IBAction)saveAction:(id)sender
{
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    SaveAsController *vc = [sb instantiateControllerWithIdentifier:@"SaveAsController"];
    vc.delegate = self;
    vc.type = 1;
    vc.filePath = self.filePath;
    [self presentViewControllerAsSheet:vc];
}

- (IBAction)saveAsAction:(id)sender {
    NSStoryboard *sb = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    SaveAsController *vc = [sb instantiateControllerWithIdentifier:@"SaveAsController"];
    vc.delegate = self;
    vc.filePath = self.filePath;
    [self presentViewControllerAsSheet:vc];
}

- (void)SaveAsControllerDidSubmitAction:(SaveAsController *)vc withName:(NSString *)name
{
    if (name.length < 1) {
        return;
    }
    
    if (vc.type == 1) {
        NSString *oldName = [DTFileManager fileNameFromPath:self.filePath];
        if (![oldName isEqual:name]) {
            [DTFileManager deleteItemWithPath:self.filePath];
        }
    }
    
    NSString *toPath = self.filePath.stringByDeletingLastPathComponent;
    NSString *string = fileTextView.string;
    if (string.length && toPath.length && name.length) {
        NSString *toFilePath = [toPath stringByAppendingPathComponent:name];
        if (![name hasSuffix:@".txt"]) {
            toFilePath = [toFilePath stringByAppendingString:@".txt"];
        }
        [string writeToFile:toFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
    
    [self didEditFinish];
}

@end
