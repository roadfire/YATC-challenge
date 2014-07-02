//
//  SMLViewController.m
//  YATC-challenge
//
//  Created by Michael Ball on 6/16/14.
//  Copyright (c) 2014 Source Main LLC. All rights reserved.
//

#import "SMLViewController.h"
#import "SMLTwitterEntry.h"
#import "SMLTwitterLoader.h"

@interface SMLViewController ()


@property (nonatomic) UITableViewCell *prototypeCell;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSMutableArray<SMLTwitterEntry> *twitterTimeline;
@property (nonatomic) SMLTwitterLoader *twitterLoader;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@end

@implementation SMLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Hello World");
    self.twitterLoader = [[SMLTwitterLoader alloc] init];
    
    
    NSDictionary *params = @{@"count" : @"100"};
    
    [self.activityIndicator startAnimating];
    
    if (self) {
        
        [self.twitterLoader loadTwitterDataWithCallback:@"https://api.twitter.com"
         @"/1.1/statuses/home_timeline.json" withParams:params withCallback:^(NSArray *results) {
             self.twitterTimeline = [[NSMutableArray alloc] initWithCapacity:100];
             for( NSDictionary *entry in results){
                 SMLTwitterEntry *newEntry = [[SMLTwitterEntry alloc] init];
                 newEntry.username = entry[@"user"][@"name"];
                 newEntry.detail = entry[@"text"];
                 newEntry.iconImageUrl = entry[@"user"][@"profile_image_url"];
                 [self.twitterTimeline addObject:newEntry];
             }
             
             NSLog(@"Timeline Response: %@\n", results);
             [self.activityIndicator stopAnimating];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         }];
    }
}



- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    if(self.twitterTimeline != nil)
    {
        return self.twitterTimeline.count;
    }
    return 0;
}

- (UITableViewCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    return _prototypeCell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withEntry:(SMLTwitterEntry *)entry downloadImage:(bool)downloadImage
{
    cell.textLabel.text = entry.username;
    cell.detailTextLabel.text = entry.detail;
    
    if(entry.userIcon == nil){
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        if(downloadImage){
            [self.twitterLoader loadImageWithCallback:entry.iconImageUrl withCallback:^(UIImage *image) {
                entry.userIcon = image;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    
                    if (cell) {
                        cell.imageView.alpha = 0;
                        cell.imageView.image = image;
                        [UIView animateWithDuration:1.0 animations:^{
                            cell.imageView.alpha = 1;
                        }];
                    }
                });
            }];
        }
    } else {
        cell.imageView.image = entry.userIcon;
    }
    
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSDictionary *entry = self.twitterTimeline[indexPath.row];
    
    //populates the cell
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath withEntry:entry downloadImage:false];
    
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
    [self configureCell:cell forRowAtIndexPath:indexPath withEntry:entry downloadImage:true];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
