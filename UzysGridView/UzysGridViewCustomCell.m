//
//  UzysGridViewCustomCell.m
//  UzysGridView
//
//  Created by Uzys on 11. 11. 10..
//  Copyright (c) 2011 Uzys. All rights reserved.
//

#import "UzysGridViewCustomCell.h"

@implementation UzysGridViewCustomCell

@synthesize textLabel;
@synthesize backgroundView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // Background view
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectNull] autorelease];
        self.backgroundView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.backgroundView];
        
        self.textLabel = [[[UILabel alloc] initWithFrame:CGRectNull] autorelease];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont systemFontOfSize:12];
        self.textLabel.center = self.center;

        [self addSubview:self.textLabel];
        [self bringSubviewToFront:self.ButtonDelete];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int inset = 5;
    
    // Background view
    self.backgroundView.frame = self.bounds;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Layout label background
    CGRect f = CGRectMake(0, 
                          0, 
                          self.textLabel.superview.bounds.size.width,
                          self.textLabel.superview.bounds.size.height);
    self.textLabel.frame = CGRectInset(f, inset, 0);
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)dealloc
{
    [textLabel release];
    [backgroundView release];
    [super dealloc];
}

@end
