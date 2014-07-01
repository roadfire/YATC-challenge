//
//  SMLTwitterEntry.h
//  YATC-challenge
//
//  Created by Michael Ball on 7/1/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//
@protocol SMLTwitterEntry @end

@interface SMLTwitterEntry : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UIImage *userIcon;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *iconImageUrl;
//@property (nonatomic, strong) NSString *appURLString;
@end