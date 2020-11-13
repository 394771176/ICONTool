//
//  ViewController.m
//  IconTool
//
//  Created by cheng on 2020/11/10.
//

#import "ViewController.h"
#import "NSUserDataManager.h"
#import "DTFileManager.h"

@interface ViewController () <NSTextFieldDelegate> {
    
    IBOutlet NSTextField *imageTextField;
    IBOutlet NSTextField *imageTextField2;
    
    IBOutlet NSView *imageShowBgView;
    IBOutlet NSImageView *imageShowView;
    
    IBOutlet NSButton *clearImageBtn;
    
    IBOutlet NSButton *exportImageBtn;
    
    IBOutlet NSPopUpButton *fileSelectBtn;
    
    IBOutlet NSTextField *fileTextField;
    
    IBOutlet NSTextField *exportImageTextField;
    
    NSImage *_icon;
    
    NSString *fileDir;
    NSArray *fileArray;
    NSInteger selectFileIndex;
    
    NSMutableDictionary *_exportImageDict;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    imageTextField.delegate = self;
    imageTextField2.delegate = self;
    fileTextField.delegate = self;
    
    imageShowBgView.wantsLayer = YES;
    imageShowBgView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    imageShowBgView.hidden = YES;
    imageTextField2.hidden = imageShowBgView.hidden;
    
    [NSUserDataManager setPathForTextField:imageTextField withKey:@"imageTextField_key"];
    [NSUserDataManager setPathForTextField:fileTextField withKey:@"fileTextField_key"];
    [NSUserDataManager setPathForTextField:exportImageTextField withKey:@"exportImageTextField_key"];
    
    [self getFileTextArray];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    [self getShowImage];
}

- (IBAction)clearImageAction:(id)sender {
    _icon = nil;
    imageShowBgView.hidden = YES;
    imageTextField2.hidden = imageShowBgView.hidden;
    imageTextField.stringValue = @"";
    [imageTextField becomeFirstResponder];
}

- (IBAction)changeFileAction:(NSPopUpButton *)sender {
    selectFileIndex = sender.indexOfSelectedItem;
    NSString *filePath = fileTextField.stringValue;
    if (filePath.length) {
        NSString *file = [fileArray objectAtIndex:selectFileIndex];
        fileTextField.stringValue = [fileDir stringByAppendingPathComponent:file];
    }
}

- (IBAction)exportImageAction:(id)sender {
    if (_icon == nil) {
        [self showAlertTitle:@"请先导入需要处理的ICON原图" message:@"拖入图片即可" btnTitles:nil handler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    
    NSDictionary *exportDict = [self getExportDict];
    if (exportDict == nil) {
        [self showAlertTitle:@"生成格式文件不对" message:@"若不知道文件格式可清空" btnTitles:nil handler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    
    NSString *imagePath = imageTextField.stringValue;
    
    NSString *toDir = exportImageTextField.stringValue;
    if (toDir.length <= 0) {
        toDir = DESKTOP(@"IconTool");
    }
    FFCreateFolderIfNeeded(toDir);
    
    [self checkDefaultTextField];
    
    [NSUserDataManager savePathFromTextField:fileTextField withKey:@"fileTextField_key"];
    [NSUserDataManager savePathFromTextField:exportImageTextField withKey:@"exportImageTextField_key"];
    [[NSUserDataManager sharedInstance] setPath:[@(selectFileIndex) stringValue] forKey:@"selectFileIndex_key"];
    
    _exportImageDict = [NSMutableDictionary dictionary];
    NSString *file = [fileArray objectAtIndex:selectFileIndex];
    NSString *fileName = [DTFileManager fileNameFromPath:file];
    NSMutableArray *renameArr = [NSMutableArray array];
    NSMutableDictionary *radiusIcons = [NSMutableDictionary dictionary];
    [exportDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *arr, BOOL *stop) {
        NSString *toPath = toDir;
        if (![key isEqualToString:fileName]) {
            toPath = [toDir stringByAppendingPathComponent:fileName];
            FFCreateFolderIfNeeded(toPath);
        }
        toPath = [toPath stringByAppendingPathComponent:key];
        FFCreateFolderIfNeeded(toPath);
        NSMutableArray *imageNames = [NSMutableArray array];
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            NSString *name = [dict objectForKey:@"name"];
            if (name.length && ![imageNames containsObject:name]) {
                NSString *sizeStr = [dict objectForKey:@"size"];
                NSString *radius = [dict objectForKey:@"radius"];
                NSString *imgKey = [NSString stringWithFormat:@"%@_%@", sizeStr, radius];
                NSImage *img = [_exportImageDict objectForKey:imgKey];
                if (!img) {
                    if ([sizeStr rangeOfString:@"x"].length) {
                        NSArray *sizeArr = [sizeStr componentsSeparatedByString:@"x"];
                        if (sizeArr.count == 2) {
                            CGSize size = CGSizeMake([sizeArr.firstObject floatValue], [sizeArr.lastObject floatValue]);
                            if (radius.length) {
                                NSImage *icon = [radiusIcons objectForKey:radius];
                                if (!icon) {
                                    icon = [self.class cornerImage:_icon corner:[radius floatValue]];
                                }
                                if (icon) {
                                    [radiusIcons setObject:icon forKey:radius];
                                    img = [self.class resizeImage2:icon forSize:size];
                                } else {
                                    [renameArr addObject:@"圆角图片生成失败"];
                                    img = [self.class resizeImage2:_icon forSize:size];
                                }
                            } else {
                                img = [self.class resizeImage2:_icon forSize:size];
                            }
                        }
                    }
                }
                if (img) {
                    NSString *toFilePath = [toPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", name, imagePath.pathExtension]];
                    [self.class saveImage:img toPath:toFilePath];
                    [_exportImageDict setObject:img forKey:imgKey];
                    [imageNames addObject:name];
                }
            } else {
                NSLog(@"重复命名：%@", name);
                [renameArr addObject:name];
            }
        }];
    }];
    if (renameArr.count) {
        [self showAlertTitle:@"图片命名重复" message:[renameArr componentsJoinedByString:@"\n"] btnTitles:nil handler:^(NSModalResponse returnCode) {
            
        }];
    }
}

- (NSDictionary *)getExportDict
{
    if (!fileDir) {
        fileDir = [NSBundle mainBundle].resourcePath;
    }
    
    NSMutableArray *errorStr = [NSMutableArray array];
    NSString *file = [fileArray objectAtIndex:selectFileIndex];
    if (fileDir.length && file.length) {
        NSString *filePath = [fileDir stringByAppendingPathComponent:file];
        
        NSString *text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        if (text.length) {
            NSArray *arr = [text componentsSeparatedByString:@"\n"];
            NSString *dir = file.stringByDeletingPathExtension;
            NSMutableDictionary *exportDict = [NSMutableDictionary dictionary];
            NSString *radius = @"";
            for (NSString *str in arr) {
                if (str.length > 1) {
                    if ([str hasSuffix:@"#"]) {
                        dir = [str substringToIndex:str.length - 1];
                        radius = @"";
                        continue;
                    } else if ([str hasPrefix:@"R="]) {
                        radius = [str substringFromIndex:2];
                        continue;
                    }
                    
                    NSMutableArray *array = [exportDict objectForKey:dir];
                    if (!array) {
                        array = [NSMutableArray array];
                        [exportDict setObject:array forKey:dir];
                    }
                    if ([str rangeOfString:@":"].length) {
                        NSArray *a = [str componentsSeparatedByString:@":"];
                        if (a.count == 2 && [[a.lastObject lowercaseString] rangeOfString:@"x"].length) {
                            NSDictionary *d = @{@"name": a.firstObject,
                                                @"size": [a.lastObject lowercaseString],
                                                @"radius" : radius
                            };
                            [array addObject:d];
                        } else {
                            [errorStr addObject:str];
                        }
                    } else if ([str.lowercaseString rangeOfString:@"x"].length) {
                        NSDictionary *d = @{@"name": str,
                                            @"size": [str lowercaseString],
                                            @"radius" : radius
                        };
                        [array addObject:d];
                    } else {
                        [errorStr addObject:str];
                    }
                }
            }
            NSLog(@"%@", exportDict);
            if (errorStr.count) {
                [self showAlertTitle:@"图片尺寸格式不对" message:[errorStr componentsJoinedByString:@"\n"] btnTitles:nil handler:^(NSModalResponse returnCode) {
                    
                }];
                return nil;
            }
            return exportDict;
        }
    }
    return nil;
}

- (void)checkDefaultTextField
{
    NSString *toDir = DESKTOP(@"IconTool");
    if (fileTextField.stringValue.length <= 0) {
        NSString *path = [toDir stringByAppendingPathComponent:@"格式说明"];
        if (![DTFileManager isFileExist:path]) {
            FFCreateFolderIfNeeded(toDir);
            FFCreateFolderIfNeeded(path);
            
            NSString *fromPath = [NSBundle mainBundle].resourcePath;
            for (NSString *str in fileArray) {
                [DTFileManager copyItemWithPath:[fromPath stringByAppendingPathComponent:str] toPath:[path stringByAppendingPathComponent:str]];
            }
            
            NSString *str = @"README.txt";
            [DTFileManager copyItemWithPath:[fromPath stringByAppendingPathComponent:str] toPath:[path stringByAppendingPathComponent:str]];
        }
        
        NSString *file = [fileArray objectAtIndex:selectFileIndex];
        fileTextField.stringValue = [path stringByAppendingPathComponent:file];
    }
    
    if (exportImageTextField.stringValue.length <= 0) {
        exportImageTextField.stringValue = toDir;
    }
}

- (void)showAlertTitle:(NSString *)title message:(NSString *)message btnTitles:(NSArray *)btnTitles handler:(void (^)(NSModalResponse returnCode))handler
{
    NSAlert *alert = [[NSAlert alloc]init];
    
    //可以设置产品的icon
    alert.icon = [NSImage imageNamed:@"Icon.png"];//your logo
    
    //添加按钮
    if (btnTitles.count) {
        for (NSString *btnTitle in btnTitles) {
            [alert addButtonWithTitle:btnTitle];
        }
    } else {
        [alert addButtonWithTitle:@"Got it"];
        //[alert addButtonWithTitle:@"Cancel"];
    }
    
    //正文
    alert.messageText = title;
    //描述文字
    alert.informativeText = message;
    //弹窗类型 默认类型 NSAlertStyleWarning
    [alert setAlertStyle:NSAlertStyleWarning];
    //回调Block
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (handler) {
            handler(returnCode);
        }
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

#pragma mark - 修改图片尺寸

+ (void)saveImage:(NSImage *)image toPath:(NSString *)path
{
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    [imageRep setSize:[image size]];
    
    if ([path.lowercaseString hasSuffix:@".jpg"]) {
        ///jpg
        NSDictionary *imageProps = nil;
        NSNumber *quality = [NSNumber numberWithFloat:.85];
        imageProps = [NSDictionary dictionaryWithObject:quality forKey:NSImageCompressionFactor];
        NSData *imageData1 = [imageRep representationUsingType:NSBitmapImageFileTypeJPEG properties:imageProps];
        //        写文件
        [imageData1 writeToFile:path atomically:YES];
    } else {
        ///png
        NSData *imageData1 = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        //        写文件
        [imageData1 writeToFile:path atomically:YES];
    }
}

// 完全填充,变形压缩
+ (NSImage *)resizeImage:(NSImage*)sourceImage forSize:(NSSize)size {
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);

    NSImageRep *sourceImageRep = [sourceImage bestRepresentationForRect:targetFrame context:nil hints:nil];

    NSImage *targetImage = [[NSImage alloc] initWithSize:size];

    [targetImage lockFocus];
    [sourceImageRep drawInRect:targetFrame];
    [targetImage unlockFocus];

    return targetImage;
}
// 将图像居中缩放截取targetsize
+ (NSImage*)resizeImage1:(NSImage*)sourceImage forSize:(CGSize)targetSize {

    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;


    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;
    scaleFactor = (widthFactor>heightFactor)?widthFactor:heightFactor;

    CGFloat readHeight = targetHeight/scaleFactor; // 需要读取的源图像的高度或宽度
    CGFloat readWidth = targetWidth/scaleFactor;
    CGPoint readPoint = CGPointMake(
                                    widthFactor>heightFactor?0:(width-readWidth)*0.5,
                                    widthFactor<heightFactor?0:(height-readHeight)*0.5);



    NSImage *newImage = [[NSImage alloc] initWithSize:targetSize];
    CGRect thumbnailRect = {{0.0, 0.0}, targetSize};
    NSRect imageRect = {readPoint, {readWidth, readHeight}};

    [newImage lockFocus];
    [sourceImage drawInRect:thumbnailRect fromRect:imageRect operation:NSCompositingOperationCopy fraction:1.0];
    [newImage unlockFocus];

    return newImage;
}

// 等比缩放
+ (NSImage*)resizeImage2:(NSImage*)sourceImage forSize:(CGSize)targetSize
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        // scale to fit the longer
        scaleFactor = (widthFactor>heightFactor)?widthFactor:heightFactor;
        scaledWidth  = ceil(width * scaleFactor);
        scaledHeight = ceil(height * scaleFactor);

        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }

    scaledWidth /= [NSScreen mainScreen].backingScaleFactor;
    scaledHeight /= [NSScreen mainScreen].backingScaleFactor;
    
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(scaledWidth, scaledHeight)];
    CGRect thumbnailRect = {thumbnailPoint, {scaledWidth, scaledHeight}};
    NSRect imageRect = NSMakeRect(0.0, 0.0, width, height);

    [newImage lockFocus];
    [sourceImage drawInRect:thumbnailRect fromRect:imageRect operation:NSCompositingOperationCopy fraction:1.0];
    [newImage unlockFocus];
    
    return newImage;
}

+ (NSImage *)cornerImage:(NSImage *)sourceImage corner:(CGFloat)radius
{
    int w = (int) sourceImage.size.width;
    int h = (int) sourceImage.size.height;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);

    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, w, h);
    addRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);
    CGContextClip(context);

    CGImageRef cgImage = [[NSBitmapImageRep imageRepWithData:[sourceImage TIFFRepresentation]] CGImage];

    CGContextDrawImage(context, CGRectMake(0, 0, w, h), cgImage);

    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    NSImage *tmpImage = [[NSImage alloc] initWithCGImage:imageMasked size:sourceImage.size];
    NSData *imageData = [tmpImage TIFFRepresentation];
    NSImage *image = [[NSImage alloc] initWithData:imageData];
    
    return image;
}

void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth < 1 || ovalHeight < 1) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj
{
    if (obj.object == imageTextField) {
        [self getShowImage];
    } else if (obj.object == fileTextField) {
        [self getFileTextArray];
    } else if (obj.object == imageTextField2) {
        if (imageTextField2.stringValue.length) {
            _icon = nil;
            imageTextField.stringValue = imageTextField2.stringValue;
            [self getShowImage];
        }
    }
}

- (void)getShowImage
{
    if (_icon == nil) {
        NSString *str = imageTextField.stringValue;
        if (str.length && ([str.lowercaseString hasSuffix:@"jpg"] || [str.lowercaseString hasSuffix:@"png"])) {
            _icon = [[NSImage alloc] initWithContentsOfFile:str];
            if (_icon) {
                imageShowView.image = _icon;
                imageShowBgView.hidden = NO;
                imageTextField2.hidden = imageShowBgView.hidden;
                [NSUserDataManager savePathFromTextField:imageTextField withKey:@"imageTextField_key"];
                [imageTextField resignFirstResponder];
                imageTextField2.stringValue = @"";
                [imageTextField2 becomeFirstResponder];
            }
        } else {
            imageTextField.stringValue = @"";
            [imageTextField becomeFirstResponder];
        }
    }
}

- (void)getFileTextArray
{
    NSString *filePath = fileTextField.stringValue;
    if (filePath.length) {
        fileDir = filePath;
        if (![DTFileManager isFileDirectory:fileDir]) {
            fileDir = [filePath stringByDeletingLastPathComponent];
        }
        fileArray = [DTFileManager contentsWithPath:fileDir];
        int i= 0;
        selectFileIndex = 0;
        NSString *file = [filePath lastPathComponent];
        for (NSString *str in fileArray) {
            if ([str isEqualToString:file]) {
                selectFileIndex = i;
                break;
            }
            i++;
        }
        if (fileArray.count == 0) {
            fileTextField.stringValue = @"";
            [self getFileTextArray];
        }
    } else {
        fileDir = nil;
        fileArray = @[@"MacOS.txt", @"超级教练iOS.txt", @"驾考通iOS+Android.txt"];
        NSString *sel = [[NSUserDataManager sharedInstance] pathForKey:@"selectFileIndex_key"];
        if (sel) {
            selectFileIndex = [sel integerValue];
        } else {
            selectFileIndex = 2;
        }
        if (selectFileIndex > fileArray.count - 1) {
            selectFileIndex = fileArray.count - 1;
        }
    }
    [fileSelectBtn removeAllItems];
    [fileSelectBtn addItemsWithTitles:fileArray];
    [fileSelectBtn selectItemAtIndex:selectFileIndex];
}


@end
