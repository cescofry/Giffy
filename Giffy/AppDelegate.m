//
//  AppDelegate.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "AppDelegate.h"
#import "ImageDiscover.h"
#import "VideoExtractor.h"
#import "GifExporter.h"

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


- (GifExporter *)defaultExporter
{
    GifExporter *exporter = [GifExporter new];
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
            
            
            NSArray *images = [VideoExtractor imagesFromVideoURL:directory];
           
            if (!images) {
                images = [ImageDiscover imagesInFolder:directory];
            }
            

            [self.currentExporter cancel];
            self.currentExporter = [self defaultExporter];

            self.currentExporter.images = images;
            
            NSString *fileName = [NSString stringWithFormat:@"%@.gif", [directory lastPathComponent]];
            NSURL *saveURL = [[directory URLByDeletingLastPathComponent] URLByAppendingPathComponent:fileName];
            
            self.currentExporter.saveLocation = saveURL;
            [self resetSlider];
            
            [self changeButtonStatus:ButtonStatusStart];
        }
        else {
            [self cancel];
        }
    }];
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
    [self.slider setEnabled:NO];
    [self.formatTextField setEnabled:NO];
    
    NSString *statusString;
    switch (status) {
        case ButtonStatusOpen:
            statusString = @"Open";
            [self.textField setStringValue:@"Seelct a folder"];
            break;
        case ButtonStatusStart:
            statusString = @"Start";
            [self.slider setEnabled:YES];
            [self.formatTextField setEnabled:YES];
            [self sliderDidChange:self.slider];
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

- (void)resetSlider
{
    self.slider.maxValue = 2.0;
    self.slider.minValue = 0.1;
    self.slider.floatValue = 1.0;
    
    [self sliderDidChange:self.slider];
}

- (IBAction)sliderDidChange:(NSSlider *)sender
{
    CGSize format = [self.currentExporter originalFormat];
    CGSize newFormat = CGSizeMake(format.width * sender.floatValue, format.height * sender.floatValue);
    self.formatTextField.stringValue = [NSString stringWithFormat:@"%.0f x %.0f", newFormat.width, newFormat.height];
    
    self.currentExporter.format = newFormat;
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
