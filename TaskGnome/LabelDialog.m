//
//  LabelDialog.m
//  TaskGnome
//
//  Created by Lion User on 12/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

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
