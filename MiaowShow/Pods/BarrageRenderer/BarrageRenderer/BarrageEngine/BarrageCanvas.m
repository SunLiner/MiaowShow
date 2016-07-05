// Part of BarrageRenderer. Created by UnAsh.
// Blog: http://blog.exbye.com
// Github: https://github.com/unash/BarrageRenderer

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2015年 UnAsh.
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

#import "BarrageCanvas.h"

@implementation BarrageCanvas

- (instancetype)init
{
    if (self = [super init]) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _margin = UIEdgeInsetsZero;
        _masked = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.superview && !CGRectEqualToRect(self.frame, self.superview.bounds)) {
        self.frame = UIEdgeInsetsInsetRect(self.superview.bounds, self.margin);
    }
}

- (void)setMargin:(UIEdgeInsets)margin
{
    if(!UIEdgeInsetsEqualToEdgeInsets(margin, _margin))
    {
        _margin = margin;
        [self setNeedsLayout];
    }
}

- (void)didMoveToSuperview
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.masked) return [super hitTest:point withEvent:event];
    for (UIView *view in self.subviews) {
        UIView *responder = [view hitTest:[view convertPoint:point fromView:self] withEvent:event];
        if (responder) return responder;
    }
    return nil;
}

@end
