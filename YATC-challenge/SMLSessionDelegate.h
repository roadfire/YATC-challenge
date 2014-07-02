//
//  SMLSessionDelegate.h
//  YATC-challenge
//
//  Created by Michael Ball on 7/2/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//

@interface SMLSessionDelegate : NSObject<NSURLSessionDataDelegate>

typedef void(^DelegateCallback)(CGFloat totalBytes, CGFloat receivedBytes);

- (instancetype)initWithCallback:(DelegateCallback)callback;

@end