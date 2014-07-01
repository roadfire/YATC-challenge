//
//  SMLViewController.m
//  YATC-challenge
//
//  Created by Michael Ball on 6/16/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//

#import "SMLViewController.h"
#import <Accounts/Accounts.h>
#import "SMLTwitterEntry.h"

@interface SMLViewController ()


@property (nonatomic) UITableViewCell *prototypeCell;
@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSMutableArray<SMLTwitterEntry> *twitterTimeline;

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
                              NSArray *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  self.twitterTimeline = [[NSMutableArray alloc] initWithCapacity:100];
                                  for( NSDictionary *entry in timelineData){
                                      SMLTwitterEntry *newEntry = [[SMLTwitterEntry alloc] init];
                                      newEntry.username = entry[@"user"][@"name"];
                                      newEntry.detail = entry[@"text"];
                                      newEntry.iconImageUrl = entry[@"user"][@"profile_image_url"];
                                      [self.twitterTimeline addObject:newEntry];
                                  }

                                  NSLog(@"Timeline Response: %@\n", timelineData);
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
    return self.twitterTimeline.count;
}

- (UITableViewCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    return _prototypeCell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withEntry:(SMLTwitterEntry *)entry
{
    cell.textLabel.text = entry.username;
    cell.detailTextLabel.text = entry.detail;
    
    if(entry.userIcon == nil){
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        [self loadImageFrom:entry.iconImageUrl withCallback:^(UIImage *image) {
            entry.userIcon = image;
        }];
        
    } else {
        cell.imageView.image = entry.userIcon;
    }
    
    
    
}

- (void)loadImageFrom:(NSString *)urlString withCallback:(void (^)(UIImage *image))callback
{
    NSLog(urlString);
    
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
                
                /*
                 dispatch_async(dispatch_get_main_queue(), ^{
                 self.imageView.image = image;
                 [UIView animateWithDuration:1.0 animations:^{
                 self.imageView.alpha = 1;
                 }];
                 
                 });
                 */
            }
        }
    }];
    [task resume];
}

- (void) loadFromURL: (NSURL*) url callback:(void (^)(UIImage *image))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            callback(image);
        });
    });
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSDictionary *entry = self.twitterTimeline[indexPath.row];
    
    //populates the cell
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath withEntry:entry];
    
    CGFloat width = self.tableView.frame.size.width; //minus the 2 x margin
    
    CGFloat imageHeight = 0;
    CGFloat imageWidth = 0;
    if(self.prototypeCell.imageView.image != nil){
        imageHeight = self.prototypeCell.imageView.image.size.height;
        imageWidth = self.prototypeCell.imageView.image.size.height;
        width = width - imageWidth - 40;
    }
    
    self.prototypeCell.detailTextLabel.frame = CGRectMake(0,0, width, 0);
    self.prototypeCell.textLabel.frame = CGRectMake(0,0, width, 0);
    
    [self.prototypeCell.textLabel sizeToFit];
    [self.prototypeCell.detailTextLabel sizeToFit];
    [self.prototypeCell sizeToFit];
    
    CGFloat usernameHeight = self.prototypeCell.textLabel.frame.size.height;
    CGFloat detailHeight = self.prototypeCell.detailTextLabel.frame.size.height;
    
    CGFloat textHeight = detailHeight + usernameHeight;
    
    if(textHeight > imageHeight)
    {
        return textHeight + 10;
    } else {
        return imageHeight + 10;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *entry = self.twitterTimeline[indexPath.row];
    
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
