/**********************************************************************
 TaskTableCell.m
 
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


#import "TaskTableCell.h"

@interface TaskTableCell ()

@property (nonatomic, weak) IBOutlet UILabel* lblTaskName;
@property (nonatomic, weak) IBOutlet UILabel* lblCategory;
@property (nonatomic, weak) IBOutlet UILabel* lblDue;
@property (nonatomic, weak) IBOutlet UILabel* lblPriority;

@end

@implementation TaskTableCell

@synthesize lblTaskName = _lblTaskName;
@synthesize lblCategory = _lblCategory;
@synthesize lblDue = _lblDue;
@synthesize lblPriority = _lblPriority;

NSDateFormatter * formatter;

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


- (NSString *)formatDate:(NSDate *)dt
{
    if (formatter) {
        return [formatter stringFromDate:dt];
    } else {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy"];
        return [self formatDate:dt];
    }
}

- (void)makeRed
{
    UIColor *color = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    [_lblTaskName setTextColor:color];
}
     
- (void)makeBlue
{
    UIColor *color = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    [_lblTaskName setTextColor:color];
}

- (void)makeGrey
{
    UIColor *color = [[UIColor alloc] initWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    [_lblTaskName setTextColor:color];
}

- (void)makeBlack
{
    UIColor *color = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    [_lblTaskName setTextColor:color];
}

- (void)makeMoreBackground
{
    UIColor *color = [[UIColor alloc] initWithRed:(247.0/256.0) green:1.0 blue:(243.0/256.0) alpha:1.0];
    //[[self contentView] setBackgroundColor:color];
//    [self setBackgroundColor:color];
    if (self.backgroundView == nil) {
        self.backgroundView = [[UIView alloc] init];
    }
    [self.backgroundView setBackgroundColor:color];
    //[self.backgroundView setNeedsDisplay];
}

- (void)makeStandardBackground
{
    UIColor *color = [[UIColor alloc] initWithWhite:1.0 alpha:1.0];
    if (self.backgroundView == nil) {
        self.backgroundView = [[UIView alloc] init];
    }
    [self.backgroundView setBackgroundColor:color];
}

- (void)setTaskName:(NSString*)name
{
    _lblTaskName.text = name;
}

- (void)setCategoryName:(NSString *)cat_name
{
    _lblCategory.text = cat_name;
}

- (void)setDue:(NSDate *)due
{
    _lblDue.text = [self formatDate:due];
}

- (void)setPriority:(int)priority
{
    if (priority > 4) {
        _lblPriority.text = @"-";
    } else {
        _lblPriority.text = [[NSString alloc] initWithFormat:@"%d",priority];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = [self frame];
    [self adjustSizes:frame.size.width];
}

- (void)adjustSizes:(int)width
{
    int width_details = 50;
    CGRect frame = [_lblPriority frame];
    int width_priority = frame.origin.x + frame.size.width + 5;
    
    frame = [_lblTaskName frame];
    frame.size.width = width - width_details - width_priority;;
    [_lblTaskName setFrame:frame];
    
    frame = [_lblCategory frame];
    frame.size.width = width * 0.5;
    [_lblCategory setFrame:frame];
    
    int dt_width = width * 0.3;
    frame.origin.x = width - dt_width - width_details;
    frame.size.width = dt_width;
    [_lblDue setFrame:frame];
    
    
    //_lblTaskName.frame.size.width = width - 50;
    
}


@end
