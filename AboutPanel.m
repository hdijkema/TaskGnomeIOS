/**********************************************************************
 AboutPanel.m
 
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


#import "AboutPanel.h"
#import "Util.h"

@interface AboutPanel()

@property (nonatomic, weak) IBOutlet UITextView * aboutText;
@property (nonatomic, weak) IBOutlet UIButton * doneButton;

@end


@implementation AboutPanel

@synthesize aboutText = _aboutText;
@synthesize doneButton = _doneButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = [self frame];
    int width = frame.size.width;
    
    if (IPHONE) {
        int yb = 20;
        frame = [_aboutText frame];
        frame.origin.x = 15;
        frame.origin.y = yb;
        frame.size.width = width - 30;
        int h = frame.size.height;
        [_aboutText setFrame:frame];
        
        frame = [_doneButton frame];
        frame.origin.x = 15;
        frame.origin.y = yb + h + 10;
        frame.size.width = width - 30;
        [_doneButton setFrame:frame];
    }
    
}

@end
