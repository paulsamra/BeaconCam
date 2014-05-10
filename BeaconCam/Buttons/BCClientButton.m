//
//  BCBeaconModeButton.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCClientButton.h"
#import "BCStyleKit.h"

@implementation BCClientButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [BCStyleKit drawModeButtonWithFrame:rect text:@"Client" highlighted:self.highlighted];
}

@end