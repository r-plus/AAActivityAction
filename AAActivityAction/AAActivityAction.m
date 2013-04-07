//
// AAActivityAction.m
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2013 r-plus. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AAActivityAction.h"
#import "AAActivity.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#ifdef __IPHONE_6_0
# define ALIGN_CENTER NSTextAlignmentCenter
#else
# define ALIGN_CENTER UITextAlignmentCenter
#endif

@interface AAActivityAction()
@property (nonatomic, assign, readonly) CGFloat activityWidth;
@property (nonatomic, assign, readonly) CGFloat rowHeight;
@property (nonatomic, assign, readonly) NSUInteger numberOfActivitiesInRow;
@end

@implementation AAActivityAction

const CGFloat kTitleHeight = 45.0f;
const CGFloat kPanelViewBottomMargin = 5.0f;
const CGFloat kPanelViewSideMargin = 20.0f;

#pragma mark InternalGetter

- (CGFloat)activityWidth
{
    // iPhone : 29:60
    //        : 59:90
    // iPad   : 74:105
    return _imageSize + 1.0f + 30.0f;
}

- (CGFloat)rowHeight
{
    // iPhone : 70
    //        : 100
    // iPad   : 115
    return self.activityWidth + 10.0f;
}

- (NSUInteger)numberOfActivitiesInRow
{
    // FIXME: more easy.
    if (_panelView)
        return (_panelView.frame.size.width - 2 * kPanelViewSideMargin) / self.activityWidth;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    return ((isLandscape ? self.bounds.size.height : self.bounds.size.width) - 2 * kPanelViewSideMargin) / self.activityWidth;
}

- (NSUInteger)numberOfRowFromCount:(NSUInteger)count
{
    NSUInteger rowsCount = (NSUInteger)(count / self.numberOfActivitiesInRow);
    rowsCount += (count % self.numberOfActivitiesInRow > 0) ? 1 : 0;
    return rowsCount;
}

#pragma mark Initialization

- (id)initWithActivityItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities imageSize:(AAImageSize)imageSize
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Forced resize to iPad size on iPad.
        _imageSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? AAImageSizeiPad : imageSize;
        
        // check supported activitiy
        NSMutableArray *array = [NSMutableArray array];
        for (AAActivity *activity in applicationActivities)
            if ([activity canPerformWithActivityItems:activityItems])
                [array addObject:activity];
        _activities = array;
        
        _activityItems = activityItems;
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self setAutoresizesSubviews:YES];
        
        UIControl *baseView = [[UIControl alloc] initWithFrame:self.frame];
        baseView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        [baseView addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventTouchUpInside];
        
        baseView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self addSubview:baseView];
        
        NSUInteger rowsCount = [self numberOfRowFromCount:[_activities count]];
        CGFloat height = self.rowHeight * rowsCount + kTitleHeight;
        CGRect baseRect = CGRectMake(0, baseView.frame.size.height - height - kPanelViewBottomMargin, baseView.frame.size.width, height);
        _panelView = [[AAPanelView alloc] initWithFrame:baseRect];
        _panelView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
        _panelView.transform = CGAffineTransformMakeScale(1.0, 0.1);
        [baseView addSubview:_panelView];
        [UIView animateWithDuration:0.1 animations:^ {
            _panelView.transform = CGAffineTransformIdentity;
        }];
        
        [self addActivities:_activities];
    }
    return self;
}

- (void)addActivities:(NSArray *)activities
{
    CGFloat x = 0;
    CGFloat y = 0;
    NSUInteger count = 0;
    CGFloat activityWidth = self.activityWidth;
    for (AAActivity *activity in activities) {
        count++;
        // icon layout by -[self layoutSubviews];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, activityWidth, activityWidth)];
        //button.backgroundColor = [UIColor greenColor];
        button.tag = count - 1;
        [button addTarget:self action:@selector(invokeActivity:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:activity.image forState:UIControlStateNormal];
        CGFloat sideWidth = activityWidth - activity.image.size.height;
        CGFloat leftInset = roundf(sideWidth / 2.0f);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, leftInset, sideWidth, sideWidth - leftInset);
        button.accessibilityLabel = activity.title;
        button.showsTouchWhenHighlighted = _imageSize == AAImageSizeSmall ? YES : NO;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, activity.image.size.height + 2.0f, activityWidth, 10.0f)];
        label.textAlignment = ALIGN_CENTER;
        label.backgroundColor = [UIColor clearColor];
        //label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        label.shadowOffset = CGSizeMake(0, 1);
        label.text = activity.title;
        CGFloat fontSize = 11.0f;
        if (_imageSize == AAImageSizeNormal)
            fontSize = 12.0f;
        else if (_imageSize == AAImageSizeiPad)
            fontSize = 15.0f;
        label.font = [UIFont systemFontOfSize:fontSize];
        label.numberOfLines = 0;
        [label sizeToFit];
        CGRect frame = label.frame;
        frame.origin.x = roundf((button.frame.size.width - frame.size.width) / 2.0f);
        label.frame = frame;
        [button addSubview:label];
        
        [_panelView addSubview:button];
    }
}

#pragma mark Action

- (void)invokeActivity:(UIButton *)button
{
    AAActivity *activity = [_activities objectAtIndex:button.tag];
    if (activity.actionBlock)
        activity.actionBlock(activity, _activityItems);
    [self dismissActionSheet];
}

#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutActivities];
    [_panelView setNeedsDisplay];
}

- (void)layoutActivities
{
    //// re-layouting panelView.
    NSUInteger rowsCount = [self numberOfRowFromCount:[_activities count]];
    CGFloat height = self.rowHeight * rowsCount + kTitleHeight;
    _panelView.frame = CGRectMake(0, _panelView.superview.frame.size.height - height - kPanelViewBottomMargin, _panelView.superview.frame.size.width, height);
    
    //// re-layouting activities.
    CGFloat x = 0;
    CGFloat y = 0;
    NSUInteger count = 0;
    CGFloat activityWidth = self.activityWidth;
    CGFloat spaceWidth = (_panelView.frame.size.width - (activityWidth * self.numberOfActivitiesInRow) - (2 * kPanelViewSideMargin)) / (self.numberOfActivitiesInRow - 1);
    for (UIButton *button in _panelView.subviews) {
        count++;
        // FIXME: more clean and easy readable code.
        x = kPanelViewSideMargin + (activityWidth + spaceWidth) * (CGFloat)(count % self.numberOfActivitiesInRow == 0 ? self.numberOfActivitiesInRow - 1 : count % self.numberOfActivitiesInRow - 1);
        y = kPanelViewSideMargin + self.rowHeight * ([self numberOfRowFromCount:count] - 1);
        
        button.frame = CGRectMake(x, y, activityWidth, activityWidth);
    }
}

#pragma mark Appearence

- (void)show
{
    // for keyboard overlay.
    // But not perfect fix for all case.
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [UIApplication sharedApplication].windows) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    UIView *topView = [[UIApplication sharedApplication].keyWindow.subviews objectAtIndex:0];
    
    [self showInView:keyboardWindow ? : topView];
}

- (void)showInView:(UIView *)view
{
    _panelView.title = self.title;
    self.frame = view.bounds;
    [view addSubview:self];
    _isShowing = YES;
}

- (void)dismissActionSheet
{
    if (self.isShowing) {
        [UIView animateWithDuration:0.1 animations:^ {
            _panelView.transform = CGAffineTransformMakeScale(1.0, 0.2);
        } completion:^ (BOOL finished){
            [self removeFromSuperview];
        }];
        _isShowing = NO;
    }
}

@end
