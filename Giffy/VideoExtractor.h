//
//  VideoExtractor.h
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^VideoExtractorComplition)(NSArray *);

@interface VideoExtractor : NSObject

+ (BOOL)canExportFromURL:(NSURL *)url;
+ (void)imagesFromVideoURL:(NSURL *)url complition:(VideoExtractorComplition)complition;
+ (void)imagesFromVideoURL:(NSURL *)url framesPerSecond:(NSUInteger)frames complition:(VideoExtractorComplition)complition;

@end
