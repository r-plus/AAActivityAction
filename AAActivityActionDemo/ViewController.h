//
//  ViewController.h
//  AAActivityActionDemo
//
//  Created by hyde on 2013/03/31.
//  Copyright (c) 2013年 r-plus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)buttonClicked:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *iconSizeSetting;

@end
