//
//  AppDelegate.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "AppDelegate.h"
#import "ImageDiscover.h"
#import "GifExporter.h"

typedef NS_ENUM(NSUInteger, ButtonStatus) {
    ButtonStatusOpen,
    ButtonStatusCancel,
    ButtonStatusView
};

static NSUInteger maxNumberOfSections = 10;

@interface AppDelegate () <GifExporterDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) GifExporter *currentExporter;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.levelIndicator.maxValue = maxNumberOfSections;
    self.levelIndicator.floatValue = 0.0;
    [self changeButtonStatus:ButtonStatusOpen];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (GifExporter *)defaultExporter
{
    GifExporter *exporter = [GifExporter new];
    exporter.delegate = self;
    exporter.frameRate = 24;
    exporter.scale = 0.2;

    return exporter;
}

#pragma mark - actions;

- (void)openDialog
{
    
    self.levelIndicator.maxValue = maxNumberOfSections;
    self.levelIndicator.floatValue = 0.0;
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowsOtherFileTypes:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        NSURL *directory = [[panel URLs] firstObject];
        if (directory) {
            NSArray *images = [ImageDiscover imagesInFolder:directory];

            [self.currentExporter cancel];
            self.currentExporter = [self defaultExporter];

            self.currentExporter.images = images;
            
            NSString *fileName = [NSString stringWithFormat:@"%@.gif", [directory lastPathComponent]];
            NSURL *saveURL = [[directory URLByDeletingLastPathComponent] URLByAppendingPathComponent:fileName];
            
            self.currentExporter.saveLocation = saveURL;
            [self.currentExporter execute];
            
            [self changeButtonStatus:ButtonStatusCancel];
        }
        else {
            [self cancel];
        }
    }];
}

- (void)cancel
{
    [self.currentExporter cancel];
    [self changeButtonStatus:ButtonStatusOpen];
}

- (void)view
{
    [[NSWorkspace sharedWorkspace] openURL:self.currentExporter.saveLocation];
}

#pragma mark - button

- (void)changeButtonStatus:(ButtonStatus)status
{
    NSString *statusString;
    switch (status) {
        case ButtonStatusOpen:
            statusString = @"Open";
            break;
        case ButtonStatusCancel:
            statusString = @"Cancel";
            break;
        case ButtonStatusView:
            statusString = @"View";
            break;
        default:
            break;
    }
    
    self.button.title = statusString;
    self.button.tag = status;
}

- (IBAction)didTapButton:(NSButton *)sender
{
    switch (sender.tag) {
        case ButtonStatusOpen:
            [self openDialog];
            break;
        case ButtonStatusCancel:
            [self cancel];
            break;
        case ButtonStatusView:
            [self view];
            break;
        default:
            break;
    }
}

#pragma mark - exporter

- (void)gifExporter:(GifExporter *)exporter processedImage:(NSImage *)image index:(NSUInteger)index outOfTotal:(NSUInteger)total
{
    [self.textField setStringValue:[NSString stringWithFormat:@"Processing              %ld/%ld", index, total]];
    
    
    float value = ((float) maxNumberOfSections / total) * (index + 1);
    [self.levelIndicator setFloatValue:value];
}

- (void)gifExporterFinished:(GifExporter *)exporter
{
    [self.textField setStringValue:@"Done"];
    [self changeButtonStatus:ButtonStatusView];
}

@end
