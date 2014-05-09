//
//  BCSubmitButton.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCSubmitButton.h"
#import "BCStyleKit.h"

@implementation BCSubmitButton

- (void)drawRect:(CGRect)rect
{
    [BCStyleKit drawModeButtonWithFrame:rect text:@"Submit" highlighted:self.highlighted];
}

@end