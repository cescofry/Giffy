//
//  GifExporter.h
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GifExporterDelegate;

@interface GifExporter : NSObject

@property (nonatomic, copy) NSArray *images;
@property (nonatomic, strong) NSURL *imagesLocation;
@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, strong) NSURL *saveLocation;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign, readonly) BOOL isExecuting;

@property (nonatomic, assign) id<GifExporterDelegate> delegate;

- (void)execute;
- (void)cancel;

@end


@protocol GifExporterDelegate <NSObject>

- (void)gifExporter:(GifExporter *)exporter processedImage:(NSImage *)image index:(NSUInteger)index outOfTotal:(NSUInteger)total;
- (void)gifExporterFinished:(GifExporter *)exporter;

@end