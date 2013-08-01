//
//  SwitchCell.m
//  TaskGnome
//
//  Created by Lion User on 17/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

#import "SwitchCell.h"

@interface SwitchCell()

@property (nonatomic, weak) IBOutlet UILabel * the_title;
@property (nonatomic, weak) IBOutlet UISwitch * the_switch;

@end

@implementation SwitchCell

@synthesize the_switch = _the_switch;
@synthesize the_title = _the_title;

BOOL do_layout = TRUE;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)preventLayout
{
    do_layout = FALSE;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (do_layout) {
        CGRect frame = [self frame];
        int width = frame.size.width;

        frame = [_the_switch frame];
        frame.origin.x = width - frame.size.width - 25;
        [_the_switch setFrame:frame];
    }
}

- (void)setTitle:(NSString *)title
{
    _the_title.text = title;
}

- (void)setSwitch:(BOOL)on
{
    _the_switch.on = on;
}

- (BOOL)getSwitch
{
    return _the_switch.on;
}


@end
