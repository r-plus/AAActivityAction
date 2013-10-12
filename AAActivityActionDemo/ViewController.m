//
//  ViewController.m
//  AAActivityActionDemo
//
//  Created by hyde on 2013/03/31.
//  Copyright (c) 2013年 r-plus. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AAActivityAction.h"
#import "AAActivity.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(id)sender {
    AAImageSize imageSize = [self iconSizeSetting].selectedSegmentIndex == 0 ? AAImageSizeSmall : AAImageSizeNormal;
    UIImage *image = [UIImage imageNamed:(imageSize == AAImageSizeSmall ? @"Safari-Small.png" : @"Safari.png")];
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i=0; i<15; i++) {
        AAActivity *activity = [[AAActivity alloc] initWithTitle:[@"Safari" stringByAppendingFormat:@"%d", i]
                                                           image:image
                                                     actionBlock:^(AAActivity *activity, NSArray *activityItems) {
            NSLog(@"doing activity = %@, activityItems = %@", activity, activityItems);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[activityItems objectAtIndex:0]]];
        }];
        [array addObject:activity];
    }
    
    AAActivityAction *aa = [[AAActivityAction alloc] initWithActivityItems:@[@"http://www.apple.com/"]
                                                     applicationActivities:array
                                                                 imageSize:imageSize];
    aa.title = @"sample title";
    [aa show];
}

- (void)viewDidUnload {
    [self setIconSizeSetting:nil];
    [super viewDidUnload];
}
@end
