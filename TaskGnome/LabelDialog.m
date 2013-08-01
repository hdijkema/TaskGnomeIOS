/**********************************************************************
 LabelDialog.m
 
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

#import "LabelDialog.h"
#import "TextFieldInput.h"

@interface LabelDialog ()

@property (nonatomic, weak) TextFieldInput IBOutlet *input;
@property (nonatomic, weak) UINavigationItem IBOutlet *bar;

@property (nonatomic, strong) NSString * hint;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * labelTitle;

@end

@implementation LabelDialog

@synthesize input = _input;
@synthesize bar = _bar;

@synthesize hint = _hint;
@synthesize text = _text;
@synthesize labelTitle = _labelTitle;

void (^cb)(NSString *);

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _input = (TextFieldInput *)[self view];

    if (_text) { [_input setText:_text]; }
    if (_hint) { [_input setHint:_hint]; }
    if (_labelTitle) { _bar.title = _labelTitle; }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLabelTitle:(NSString *)t
{
    _bar.title = t;
    _labelTitle = t;
}

- (void)setHint:(NSString *)hint
{
    [_input setHint:hint];
    _hint = hint;
    
}

- (void)setText:(NSString *)text
{
    [_input setText:text];
    _text = text;
}

- (void)setCallback:(void(^)(NSString *))_cb
{
    cb = _cb;
}

- (IBAction)done:(id)sender
{
    NSString *text = [_input getText];
    cb(text);
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
