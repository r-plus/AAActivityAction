//
// AAPanelView.m
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

#import "AAPanelView.h"
#import "AAActivityAction.h"

#ifdef __IPHONE_6_0
# define ALIGN_CENTER NSTextAlignmentCenter
# define MIDDLE_TRUNCATE NSLineBreakByTruncatingMiddle
#else
# define ALIGN_CENTER UITextAlignmentCenter
# define MIDDLE_TRUNCATE UILineBreakModeMiddleTruncation
#endif

@implementation AAPanelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Many code import from SAResizibleBubble.m
// https://github.com/andrei200287/SAVideoRangeSlider/blob/master/SAVideoRangeSlider/SAResizibleBubble.m
//
//  SAResizibleBubble.m
//
// Copyright (c) 2013 Andrei Solovjev - http://solovjev.com/
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

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor *gradientTop = [UIColor colorWithWhite:0.25 alpha:0.8];
    UIColor *gradientBottom = [UIColor colorWithWhite:0.0 alpha:0.9];
    UIColor *highlightColor = [UIColor colorWithWhite:0.9 alpha:0.7];
    UIColor *strokeColor = [UIColor blackColor];
    
    //// Gradient Declarations
    NSArray *gradientColors = [NSArray arrayWithObjects:
                                     (id)gradientTop.CGColor,
                                     (id)gradientBottom.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef lineGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    UIColor *outerShadow = [UIColor blackColor];
    CGSize outerShadowOffset = CGSizeMake(0, 0);
    CGFloat outerShadowBlurRadius = 5;
    
    UIColor *highlightShadow = highlightColor;
    CGSize highlightShadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat highlightShadowBlurRadius = 0;
    
    //// Frames
    CGRect panelFrame = CGRectInset(self.bounds, 10, 5);
    
    //// Draw gradient
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:panelFrame cornerRadius:5];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, outerShadowOffset, outerShadowBlurRadius, outerShadow.CGColor);
    CGContextBeginTransparencyLayer(context, NULL);
    [roundedRectPath addClip];
    CGRect roundedRectBounds = CGPathGetPathBoundingBox(roundedRectPath.CGPath);
    CGContextDrawLinearGradient(context, lineGradient,
                                CGPointMake(CGRectGetMidX(roundedRectBounds), CGRectGetMinY(roundedRectBounds)),
                                CGPointMake(CGRectGetMidX(roundedRectBounds), CGRectGetMaxY(roundedRectBounds)),
                                0);
    CGContextEndTransparencyLayer(context);
    
    //// Highlight
    CGRect highlightRect = CGRectInset([roundedRectPath bounds], -highlightShadowBlurRadius, -highlightShadowBlurRadius);
    highlightRect = CGRectOffset(highlightRect, -highlightShadowOffset.width, -highlightShadowOffset.height);
    highlightRect = CGRectInset(CGRectUnion(highlightRect, [roundedRectPath bounds]), -1, -1);
    
    UIBezierPath* roundedRectNegativePath = [UIBezierPath bezierPathWithRect:highlightRect];
    [roundedRectNegativePath appendPath:roundedRectPath];
    roundedRectNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = highlightShadowOffset.width + round(highlightRect.size.width);
        CGFloat yOffset = highlightShadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    highlightShadowBlurRadius,
                                    highlightShadow.CGColor);
        [roundedRectPath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(highlightRect.size.width), 0);
        [roundedRectNegativePath applyTransform:transform];
        [[UIColor grayColor] setFill];
        [roundedRectNegativePath fill];
    }
    CGContextRestoreGState(context);
    CGContextRestoreGState(context);
    
    //// Stroke
    [strokeColor setStroke];
    roundedRectPath.lineWidth = 1;
    [roundedRectPath stroke];
    
    //// Upper line of title
    UIBezierPath *titleSeparateLinePath = [UIBezierPath bezierPath];
    [titleSeparateLinePath moveToPoint:CGPointMake(CGRectGetMaxX(panelFrame), CGRectGetMaxY(panelFrame) - 25.0)];
    [titleSeparateLinePath addLineToPoint:CGPointMake(CGRectGetMinX(panelFrame), CGRectGetMaxY(panelFrame) - 25.0)];
    [titleSeparateLinePath closePath];
    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 0, [UIColor blackColor].CGColor);
    [[UIColor colorWithWhite:0.7 alpha:0.3] setStroke];
    titleSeparateLinePath.lineWidth = 0.4;
    [titleSeparateLinePath stroke];
    
    //// Draw title
    UIFont *font = [UIFont systemFontOfSize:12.0];
    CGSize strSize;
    if ([self.title respondsToSelector:@selector(sizeWithAttributes:)])
        strSize = [self.title sizeWithAttributes:@{NSFontAttributeName:font}];
    else
        strSize = [self.title sizeWithFont:font];
    CGRect titleRect = CGRectMake(panelFrame.origin.x + 10.0, panelFrame.size.height - 15.0, panelFrame.size.width - 20.0, strSize.height);
    if (kCFCoreFoundationVersionNumber >= 847.20) {
        // iOS 7+
        UIColor *fontColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
        textStyle.alignment = NSTextAlignmentCenter;
        [self.title drawInRect:titleRect withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor, NSParagraphStyleAttributeName:textStyle}];
    } else {
        CGContextSetRGBFillColor(context, 0.7, 0.7, 0.7, 1.0);
        [self.title drawInRect:titleRect withFont:font lineBreakMode:MIDDLE_TRUNCATE alignment:ALIGN_CENTER];
    }
    
    // Add title tap to dissmiss
    UIButton *titleTapToDissmissControl = [[UIButton alloc] initWithFrame:titleRect];
    titleTapToDissmissControl.backgroundColor = [UIColor clearColor];
    titleTapToDissmissControl.showsTouchWhenHighlighted = YES;
    [titleTapToDissmissControl addTarget:self.delegate action:@selector(dismissActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:titleTapToDissmissControl];

    //// Cleanup
    CGGradientRelease(lineGradient);
    CGColorSpaceRelease(colorSpace);
}

@end
