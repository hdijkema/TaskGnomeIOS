//
//  TextFieldInput.m
//  TaskGnome
//
//  Created by Lion User on 17/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

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
