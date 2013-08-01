/**********************************************************************
 TextFieldInput.m
 
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


#import "TextFieldInput.h"

@interface TextFieldInput()

@property (nonatomic, weak) IBOutlet UITextField * tfText;

@end


@implementation TextFieldInput

@synthesize tfText = _tfText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _tfText.text = text;
}

- (NSString *)getText
{
    return _tfText.text;
}

- (void)setHint:(NSString *)hint
{
    _tfText.placeholder = hint;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = [self frame];
    int width = frame.size.width;
    
    frame = [_tfText frame];
    frame.origin.x = 25;
    frame.size.width = width - 50;
    [_tfText setFrame:frame];
}


@end
