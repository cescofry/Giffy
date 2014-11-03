//
//  GifExporter.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "GifExporter.h"
#import <AppKit/AppKit.h>
#import <ImageIO/ImageIO.h>

@interface GifExporter ()

@property (nonatomic, assign, readwrite) BOOL isExecuting;
@property (nonatomic, assign) BOOL isCancelled;

@end

@implementation GifExporter

- (NSArray *)images
{
    if (!_images) {
        // get all images in folder
    }
    return _images;
}

- (float)frameLength
{
    float rate = (self.frameRate)? (float) self.frameRate : 12.0;
    
    return 1.0 / rate;
}

- (CGSize)format
{
    if (_format.width <= 0.0 || _format.height <= 0.0) {
        _format = self.originalFormat;
    }
    
    return _format;
}

- (CGSize)originalFormat
{
    return [(NSImage *)[self.images firstObject] size];
}



- (void)execute
{
 
    if (!self.saveLocation || self.images.count == 0 || [self frameLength] <= 0.0) {
        return;
    }
    
    if (self.isExecuting) {
        return;
    }
    self.isExecuting = YES;
    self.isCancelled = NO;
    
    dispatch_queue_t queue = dispatch_queue_create("com.ziofrtiz.exporter", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)self.saveLocation,
                                                                            kUTTypeGIF,
                                                                            self.images.count,
                                                                            NULL);
        NSDictionary *frameProperties = @{(NSString *)kCGImagePropertyGIFDictionary : @{(NSString *)kCGImagePropertyGIFDelayTime : @([self frameLength])}};
        NSDictionary *gifProperties = @{(NSString *)kCGImagePropertyGIFDictionary : @{(NSString *)kCGImagePropertyGIFLoopCount : @0}};
        
        NSUInteger total = self.images.count;
        
        [self.images enumerateObjectsUsingBlock:^(NSImage *image, NSUInteger idx, BOOL *stop) {
            
            if (self.isCancelled) {
                *stop = YES;
                return;
            }
            
            image = [self scaleImage:image];
            
            CFDataRef data = (__bridge CFDataRef)[image TIFFRepresentation];
            
            CGImageSourceRef source = CGImageSourceCreateWithData(data, NULL);
            CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
            CGImageDestinationAddImage(destination, maskRef, (CFDictionaryRef)frameProperties);
            
            CFRelease(source);
            CFRelease(maskRef);
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(gifExporter:processedImage:index:outOfTotal:)]) {
                    [self.delegate gifExporter:self processedImage:image index:idx outOfTotal:total];
                }
            });
            
        }];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(gifExporterIsProcessing:)]) {
                [self.delegate gifExporterIsProcessing:self];
            }
        });
        
        self.images = nil;
        
        if (self.isCancelled) {
            return;
        }
        
        
        CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(gifExporterFinished:)]) {
                [self.delegate gifExporterFinished:self];
            }
        });
    });
}

- (void)cancel
{
    NSAssert(NO, @"Not implemented");
}

- (NSImage *)scaleImage:(NSImage *)image
{
    NSImage *smallImage = [[NSImage alloc] initWithSize:self.format];
    [smallImage lockFocus];
    [image setSize: self.format];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, self.format.width, self.format.height) operation:NSCompositeCopy fraction:1.0];
    [smallImage unlockFocus];
    
    return smallImage;
}


@end
