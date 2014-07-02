//
//  SMLSessionDelegate.m
//  YATC-challenge
//
//  Created by Michael Ball on 7/2/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//

#import "SMLSessionDelegate.h"

@interface SMLSessionDelegate()

@property (nonatomic, copy) DelegateCallback callback;

@end

@implementation SMLSessionDelegate

- (instancetype)initWithCallback:(DelegateCallback)callback
{
    self = [super init];
    if(self){
        self.callback = callback;
    }
    return self;
}


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    CGFloat totalBytes = dataTask.countOfBytesExpectedToReceive;
    CGFloat receivedBytes = dataTask.countOfBytesReceived;
    
    self.callback(totalBytes, receivedBytes);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    CGFloat totalBytes = dataTask.countOfBytesExpectedToReceive;
    CGFloat receivedBytes = dataTask.countOfBytesReceived;
    
    self.callback(totalBytes, receivedBytes);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    CGFloat totalBytes = task.countOfBytesExpectedToReceive;
    CGFloat receivedBytes = task.countOfBytesReceived;
    
    self.callback(totalBytes, receivedBytes);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    CGFloat totalBytes = dataTask.countOfBytesExpectedToReceive;
    CGFloat receivedBytes = dataTask.countOfBytesReceived;
    
    self.callback(totalBytes, receivedBytes);
}

@end
