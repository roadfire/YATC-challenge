//
//  SMLViewController.m
//  YATC-challenge
//
//  Created by Michael Ball on 6/16/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//

#import "SMLViewController.h"

@interface SMLViewController ()
@property (nonatomic) NSArray *timelineData;
@property (nonatomic) UITableViewCell *prototypeCell;

@end

@implementation SMLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Hello World");
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
        [self fetchTimelineForUser];
    }
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)fetchTimelineForUser
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
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/home_timeline.json"];
                 
                 NSDictionary *params = @{@"count" : @"100"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              self.timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (self.timelineData) {
                                  NSLog(@"Timeline Response: %@\n", self.timelineData);
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.tableView reloadData];
                                  });
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %d",
                                    urlResponse.statusCode);
                          }
                      }
                  }];
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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    return self.timelineData.count;
}
/*
 - (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return UITableViewAutomaticDimension;
 }
 */

- (UITableViewCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    return _prototypeCell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withEntry:(NSDictionary *)entry
{
    if ([cell isKindOfClass:[UITableViewCell class]])
    {
        cell.textLabel.text = entry[@"user"][@"name"];;
        cell.detailTextLabel.text = entry[@"text"];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSDictionary *entry = self.timelineData[indexPath.row];
    
    //populates the cell
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath withEntry:entry];
    
    CGFloat width = self.tableView.frame.size.width; //minus the 2 x margin

    self.prototypeCell.detailTextLabel.frame = CGRectMake(0,0, width, 0);
    self.prototypeCell.textLabel.frame = CGRectMake(0,0, width, 0);
    
    [self.prototypeCell.textLabel sizeToFit];
    [self.prototypeCell.detailTextLabel sizeToFit];
    [self.prototypeCell sizeToFit];
    
    CGFloat usernameHeight = self.prototypeCell.textLabel.frame.size.height;
    CGFloat detailHeight = self.prototypeCell.detailTextLabel.frame.size.height;
    
    return 10 + detailHeight + usernameHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *entry = self.timelineData[indexPath.row];
    
    //populates the cell
    [self configureCell:cell forRowAtIndexPath:indexPath withEntry:entry];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
