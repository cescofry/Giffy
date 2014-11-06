//
//  AppDelegate.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "AppDelegate.h"
#import "FolderLazyCollection.h"
#import "VideoLazyCollection.h"
#import "GifExporter.h"
#import "AspectRatio.h"

typedef NS_ENUM(NSUInteger, ButtonStatus) {
    ButtonStatusOpen,
    ButtonStatusStart,
    ButtonStatusCancel,
    ButtonStatusView
};

static NSUInteger maxNumberOfSections = 20;

@interface AppDelegate () <GifExporterDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) GifExporter *currentExporter;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self resetProgressIndicator];
    [self changeButtonStatus:ButtonStatusOpen];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (GifExporter *)defaultExporterWithLazyCollection:(AbstractLazyCollection *)lazyCollection
{
    GifExporter *exporter = [[GifExporter alloc] initWithImagesEnumerator:lazyCollection];
    exporter.delegate = self;
    exporter.frameRate = 24;

    return exporter;
}

#pragma mark - actions;

- (void)openDialog
{
    
    [self resetProgressIndicator];
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowsOtherFileTypes:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        NSURL *directory = [[panel URLs] firstObject];
        if (directory) {
            
            AbstractLazyCollection *collection = [[VideoLazyCollection alloc] initWithVideoURL:directory framesPerSecond:24];
            if (!collection) {
                collection = [[FolderLazyCollection alloc] initWithFolderURL:directory];
            }
            
            [self saveImages:collection atURL:directory];
        }
        else {
            [self cancel];
        }
    }];
}

- (void)saveImages:(AbstractLazyCollection *)images atURL:(NSURL *)url
{
    [self.currentExporter cancel];
    self.currentExporter = [self defaultExporterWithLazyCollection:images];
    
    
    NSString *fileName = [NSString stringWithFormat:@"%@.gif", [url lastPathComponent]];
    NSURL *saveURL = [[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:fileName];
    
    self.currentExporter.saveLocation = saveURL;
    [self.formatButton removeAllItems];
    
#error should be able to bind NSPopUpButton to NSPopUpCell and feed AspectRation instead of NSString
    NSArray *items = [[AspectRatio allAspectRatiosFromSize:self.currentExporter.format] valueForKeyPath:@"stringValue"];
    [self.formatButton addItemsWithTitles:items];
    
    [self changeButtonStatus:ButtonStatusStart];
}

- (void)start
{
    [self.currentExporter execute];
    [self.progressIndicator startAnimation:self];
    [self changeButtonStatus:ButtonStatusCancel];
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
    [self.formatButton setEnabled:NO];
    
    NSString *statusString;
    switch (status) {
        case ButtonStatusOpen:
            statusString = @"Open";
            [self.textField setStringValue:@"Seelct a folder"];
            break;
        case ButtonStatusStart:
            statusString = @"Start";
            [self.formatButton setEnabled:YES];
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
        case ButtonStatusStart:
            [self start];
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

#pragma mark - format

- (CGSize)sizeFromButtonString:(NSString *)string
{
    return CGSizeZero;
}

- (IBAction)popUpButtonDidChange:(NSPopUpButton *)sender
{
    self.currentExporter.format = [self sizeFromButtonString:[sender.selectedCell stringValue]];
}

- (void)resetProgressIndicator
{
    self.progressIndicator.maxValue = maxNumberOfSections;
    self.progressIndicator.doubleValue = 0.0;
    [self.progressIndicator stopAnimation:self];
    [self.progressIndicator setIndeterminate:NO];
    
}

#pragma mark - exporter

- (void)gifExporter:(GifExporter *)exporter processedImage:(NSImage *)image index:(NSUInteger)index outOfTotal:(NSUInteger)total
{
    [self.textField setStringValue:[NSString stringWithFormat:@"Processing              %ld/%ld", index, total]];
    
    
    float value = ((float) maxNumberOfSections / total) * (index + 1);
    [self.progressIndicator setDoubleValue:value];
}

- (void)gifExporterIsProcessing:(GifExporter *)exporter
{
    [self.textField setStringValue:@"Processing"];
}

- (void)gifExporterFinished:(GifExporter *)exporter
{
    [self.textField setStringValue:@"Done"];
    [self changeButtonStatus:ButtonStatusView];
}

@end
