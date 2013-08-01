//
//  TextViewCell.m
//  TaskGnome
//
//  Created by Lion User on 20/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

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
