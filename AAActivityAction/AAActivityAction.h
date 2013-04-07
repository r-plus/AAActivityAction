//
// AAActivityAction.h
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

#import <UIKit/UIKit.h>
#import "AAPanelView.h"

typedef enum AAImageSize : NSUInteger {
    AAImageSizeSmall = 29,
    AAImageSizeNormal = 59,
    AAImageSizeiPad = 74
} AAImageSize;

@interface AAActivityAction : UIView {
@private;
    NSArray *_activityItems;
    NSArray *_activities;
    AAImageSize _imageSize;
    AAPanelView *_panelView;
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign, readonly) BOOL isShowing;

- (id)initWithActivityItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities imageSize:(AAImageSize)imageSize;
// Attempt automatically use top of hierarchy view.
- (void)show;
- (void)showInView:(UIView *)view;
- (void)dismissActionSheet;
@end
