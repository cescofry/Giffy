//
//  VideoExtractor.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "VideoLazyCollection.h"
#import <AppKit/AppKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoLazyCollection ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, assign) CMTime currentTime;
@property (nonatomic, assign) CMTime progressTime;

@end


@implementation VideoLazyCollection

- (instancetype)initWithVideoURL:(NSURL *)url
{
    return [self initWithVideoURL:url framesPerSecond:24];
}

- (instancetype)initWithVideoURL:(NSURL *)url framesPerSecond:(NSUInteger)frames
{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    
    if (![[self class] isAssetPlayable:asset]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        self.imageGenerator.appliesPreferredTrackTransform = YES;

        CMTimeScale timescale  = asset.duration.timescale;
        NSInteger samplesPerFrame = timescale / frames;
        
        self.progressTime = CMTimeMake(samplesPerFrame, timescale);
        self.currentTime = CMTimeMake(0, timescale);
        
        self.count = (NSUInteger)(CMTimeGetSeconds(asset.duration) / CMTimeGetSeconds(self.progressTime));
        self.format = [[self imageAtTime:self.currentTime] size];
    }
    
    return self;
}

+ (BOOL)isAssetPlayable:(AVURLAsset *)asset
{
    // Don't know another way to do this.
    NSArray *extensions = @[@"mov", @"m4v", @"avi", @"mpeg", @"mp4", @"dv", @"quicktime"];
    return [extensions containsObject:asset.URL.pathExtension];
}

- (NSImage *)imageAtTime:(CMTime)time
{
    
    if (time.value > self.imageGenerator.asset.duration.value) {
        return nil;
    }
    
    NSError *error = nil;
    CGImageRef imgRef = [self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    NSImage *image = [[NSImage alloc] initWithCGImage:imgRef size:NSZeroSize];
    CGImageRelease(imgRef);
    
    return image;
}

- (id)nextObject
{
    NSImage *image = [self imageAtTime:self.currentTime];
    self.currentTime = CMTimeAdd(self.currentTime, self.progressTime);
    
    NSLog(@"current time: %lld, %d", self.currentTime.value, self.currentTime.timescale);
    
    return image;
}


@end
