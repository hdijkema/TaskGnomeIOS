//
//  SwitchCellNoLayout.m
//  TaskGnome
//
//  Created by Lion User on 17/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

#import "SwitchCellNoLayout.h"

@implementation SwitchCellNoLayout

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super preventLayout];
    [super layoutSubviews];
}


@end
