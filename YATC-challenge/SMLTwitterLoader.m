//
//  SMLDataLoader.m
//  YATC-challenge
//
//  Created by Michael Ball on 7/1/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMLTwitterLoader.h"
#import <Accounts/Accounts.h>
#import "SMLSessionDelegate.h"

@interface SMLTwitterLoader ()

@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation SMLTwitterLoader

- (instancetype)init
{
    self.accountStore = [[ACAccountStore alloc] init];
    return self;
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)loadImageWithCallback:(NSString *)urlString withCallback:(void (^)(UIImage *image))callback
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299)
            {
                UIImage *image = [UIImage imageWithData:data];
                callback(image);
            }
        }
    }];
    [task resume];
}

- (void)loadTwitterDataWithCallback:(NSString *)urlString withParams:(NSDictionary*) params withCallback:(void (^)(NSArray *results))callback withDelegateCallback:(DelegateCallback)delegateCallback;
{
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:urlString];
                 
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //MYDelegateHandler delegate = new myDelegate
                 //delegate.setcallbacker = ^()[{
             //docallback(yada)
             //}]
                 
                 NSURLRequest *urlRequest = [request preparedURLRequest];
                 NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

                 SMLSessionDelegate *delegate = [[SMLSessionDelegate alloc] initWithCallback:delegateCallback];
                 
                 NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                                       delegate:delegate
                                                                  delegateQueue:[NSOperationQueue currentQueue]];
                 
                 NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
                                                         completionHandler:^(NSData *responseData, NSURLResponse *urlResponse, NSError *error) {
                                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
                                                             if (responseData) {
                                                                 if (httpResponse.statusCode >= 200 &&
                                                                     httpResponse.statusCode < 300) {
                                                                     
                                                                     NSError *jsonError;
                                                                     NSArray *results =
                                                                     [NSJSONSerialization
                                                                      JSONObjectWithData:responseData
                                                                      options:NSJSONReadingAllowFragments error:&jsonError];
                                                                     if (results) {
                                                                         callback(results);
                                                                     }
                                                                     else {
                                                                         // Our JSON deserialization went awry
                                                                         NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                                                                     }
                                                                 }
                                                                 else {
                                                                     // The server did not respond ... were we rate-limited?
                                                                     NSLog(@"The response status code is %d",
                                                                           httpResponse.statusCode);
                                                                 }
                                                             }
                                                         }];
                 
                 [task resume];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    } else {
        NSLog(@"User is not signed into Twitter");
    }
}

@end