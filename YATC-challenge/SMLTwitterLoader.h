//
//  SMLDataLoader.h
//  YATC-challenge
//
//  Created by Michael Ball on 7/1/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//
#import <Social/Social.h>
#import "SMLSessionDelegate.h"

@interface SMLTwitterLoader : NSObject

- (void)loadImage :(NSString *)urlString withCallback:(void (^)(UIImage *image))callback;
- (void)loadTwitterData:(NSString *)urlString withParams:(NSDictionary*) params withProgressCallback:(ProgressCallback)progressCallback withCompleteCallback:(CompleteCallback)completeCallback;

@end