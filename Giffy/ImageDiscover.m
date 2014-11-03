//
//  ImageDiscover.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "ImageDiscover.h"
#import <AppKit/AppKit.h>

@implementation ImageDiscover

+ (NSArray *)imagesInFolder:(NSURL *)folderURL
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:folderURL includingPropertiesForKeys:nil options:0 errorHandler:nil];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    
    
    id object;
    while (object = [enumerator nextObject]) {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:(NSURL *)object];
        
        NSNumber *key = [self numberAtURL:(NSURL *)object];
        if (key) {
            dictionary[key] = image;
        }
    }
    
    NSArray *keys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *images = [NSMutableArray array];
    [keys enumerateObjectsUsingBlock:^(NSNumber *key, NSUInteger idx, BOOL *stop) {
        [images addObject:dictionary[key]];
    }];
    
    return [images copy];
}

+ (NSNumber *)numberAtURL:(NSURL *)url
{
    
    static NSRegularExpression *regEx;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       regEx = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+)" options:0 error:nil];
    });
    
    NSString *urlString = [[url absoluteString] lastPathComponent];
    
    NSTextCheckingResult *result = [regEx firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    if (result && [result numberOfRanges] > 0) {
        NSString *stringInRange = [urlString substringWithRange:[result rangeAtIndex:0]];
        return @([stringInRange integerValue]);
    }
    else {
        return nil;
    }
}

@end
