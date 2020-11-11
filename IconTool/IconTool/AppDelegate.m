//
//  AppDelegate.m
//  IconTool
//
//  Created by cheng on 2020/11/10.
//

#import "AppDelegate.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    for (NSWindow *window in NSApplication.sharedApplication.windows) {
        [window makeKeyAndOrderFront:self];
    }
    return YES;
}

@end
