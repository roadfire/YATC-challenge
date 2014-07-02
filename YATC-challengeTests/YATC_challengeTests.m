//
//  YATC_challengeTests.m
//  YATC-challengeTests
//
//  Created by Michael Ball on 6/16/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface YATC_challengeTests : XCTestCase

@end

@implementation YATC_challengeTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    int64_t total = 500;
    int64_t received = 250;
    
    CGFloat fTotal = total;
    CGFloat fReceived = received;
    
    CGFloat percent = fReceived/fTotal;
    
    XCTAssertEqual(percent, 0.5);
}

@end
