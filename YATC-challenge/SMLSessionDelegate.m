//
//  SMLSessionDelegate.m
//  YATC-challenge
//
//  Created by Michael Ball on 7/2/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//

#import "SMLSessionDelegate.h"

@interface SMLSessionDelegate()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, copy) ProgressCallback progressCallback;
@property (nonatomic, copy) CompleteCallback completeCallback;

@end

@implementation SMLSessionDelegate

- (instancetype)initWithProgressCallback:(ProgressCallback)progressCallback withCompleteCallback:(CompleteCallback)completeCallback
{
    self = [super init];
    if(self){
        self.progressCallback = progressCallback;
        self.completeCallback = completeCallback;
    }
    return self;
}


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
  
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"didFinishDownloadingToURL");
    NSData *responseData = [NSData dataWithContentsOfURL:location];
    self.completeCallback(responseData);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"dunno");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSURLResponse *response = downloadTask.response;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *headers = [httpResponse allHeaderFields];
    
    NSString *length = headers[@"content-length"];
    
    //totalBytesExpectedToWrite is always -1 converty content length to bytes
    CGFloat totalBytes = 8 * (CGFloat)[length floatValue];
    CGFloat receivedBytes = totalBytesWritten;
    
    self.progressCallback(totalBytes, receivedBytes);
}

@end
