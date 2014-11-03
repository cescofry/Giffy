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

+ (NSArray *)imagesFromVideoURL:(NSURL *)url
{
    
    if (![QTMovie canInitWithURL:url]) {
        NSLog(@"CAnnnot open file at URL %@", url.absoluteString);
        return nil;
    }
    
    NSError *error;
    QTMovie *movie = [QTMovie movieWithURL:url error:&error];
    
    
    double duration = movie.duration.timeValue;
    double index = 0.0;
    
    NSMutableArray *images = [NSMutableArray array];
    while (index <= duration) {
        QTTime time = QTMakeTime(index, 1.0);
        NSImage *image = [movie frameImageAtTime:time];
        
        if (image) {
            [images addObject:image];
            index += 0.2;
        }
        else {
            index += duration;
        }
        
        
    }
    
    return  [images copy];
}

@end
