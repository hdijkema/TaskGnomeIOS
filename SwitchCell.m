/**********************************************************************
 SwitchCell.m
 
 This file is part of TaskGnome IOS.
 
 TaskGnome is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with TaskGnome IOS.  If not, see <http://www.gnu.org/licenses/>.
 
 Copyright (c) 2013 Hans Oesterholt. All rights reserved.
 **********************************************************************/

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
