//
//  SMLSessionDelegate.h
//  YATC-challenge
//
//  Created by Michael Ball on 7/2/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//

@interface SMLSessionDelegate : NSObject<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

typedef void(^ProgressCallback)(CGFloat totalBytes, CGFloat receivedBytes);
typedef void(^CompleteCallback)(NSData* data);

- (instancetype)initWithProgressCallback:(ProgressCallback)progressCallback withCompleteCallback:(CompleteCallback)completeCallback;

@end