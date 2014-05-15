//
//  BCExitButton.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/13/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCExitButton.h"
#import "BCStyleKit.h"

@implementation BCExitButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [BCStyleKit drawModeButtonWithFrame:rect text:@"Exit" highlighted:self.highlighted];
}

@end