//
//  AboutPanel.m
//  TaskGnome
//
//  Created by Lion User on 23/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

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
