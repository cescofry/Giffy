//
//  VideoExtractor.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "VideoExtractor.h"
#import <QTKit/QTKit.h>

@implementation VideoExtractor

+ (BOOL)canExportFromURL:(NSURL *)url
{
    return [QTMovie canInitWithURL:url];
}

+ (void)imagesFromVideoURL:(NSURL *)url complition:(VideoExtractorComplition)complition
{
    return [self imagesFromVideoURL:url framesPerSecond:24 complition:complition];
}

+ (void)imagesFromVideoURL:(NSURL *)url framesPerSecond:(NSUInteger)frames complition:(VideoExtractorComplition)complition
{
    
    if (![QTMovie canInitWithURL:url] && complition) {
        NSLog(@"CAnnnot open file at URL %@", url.absoluteString);
        complition(nil);
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("com.ziofrtiz.videoExtractor", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSError *error;
        QTMovie *movie = [QTMovie movieWithURL:url error:&error];
        
        
        double duration = movie.duration.timeValue;
        double index = 0.0;
        double advancing = 1.0 / frames;
        
        NSMutableArray *images = [NSMutableArray array];
        while (index <= duration) {
            QTTime time = QTMakeTime(index, 1.0);
            NSImage *image = [movie frameImageAtTime:time];
            
            if (image) {
                [images addObject:image];
                index += advancing;
            }
            else {
                index += duration;
            }
        }
        
        if (complition) {
            complition([images copy]);
        }
    });
}

@end
