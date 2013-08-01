/**********************************************************************
 TextViewCell.m
 
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


#import "TextViewCell.h"

@interface TextViewCell ()

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property BOOL sizing;

@end

@implementation TextViewCell

@synthesize textView = _textView;

- (id)init
{
    self = [super init];
    [self myInit];
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self myInit];
    return self;
};

- (void)myInit
{
    self.sizing = FALSE;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setViewText:(NSString *)text
{
    _textView.text = text;
}

- (NSString *) getViewText
{
    return _textView.text;
}

- (void)layoutSubviews
{
        [super layoutSubviews];
    
        CGRect frame = [self frame];
        int width = frame.size.width;
        int height = _textView.frame.size.height + 25;
        frame.size.height = height;
        [self setFrame:frame];
        
        frame = [_textView frame];
        frame.size.width = width - 50;
        [_textView setFrame:frame];
}


@end
