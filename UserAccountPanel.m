//
//  UserAccountPanel.m
//  TaskGnome
//
//  Created by Lion User on 22/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

#import "UserAccountPanel.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>


@implementation UserAccountPanel

@synthesize user_email = _user_email;
@synthesize tf_password = _tf_password;
@synthesize result = _result;
@synthesize check = _check;
@synthesize done = _done;
@synthesize save = _save;
@synthesize create = _create;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUserEmail:(NSString *)email
{
    _user_email.text = email;
}

- (NSString *)getUserEmail
{
    return _user_email.text;
}

- (void)setPassword:(NSString *)password
{
    _tf_password.text = password;
}

- (NSString *) getPassword
{
    return _tf_password.text;
}

- (void)setMessage:(NSString *)message
{
    _result.text = message;
    UIColor *color = [[UIColor alloc] initWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
    [_result setTextColor:color];
}

- (void)setErrorMessage:(NSString *)message
{
    _result.text = message;
    UIColor *color = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    [_result setTextColor:color];
}

- (IBAction)handleTap:(id)sender
{
    [self dropKeyboard];
}

- (void)dropKeyboard
{
    [_user_email resignFirstResponder];
    [_tf_password resignFirstResponder];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = [self frame];
    int width = frame.size.width;
    
    if (IPHONE) {
        frame = [_user_email frame];
        frame.origin.x = 20;
        frame.size.width = width - 40;
        [_user_email setFrame:frame];
        frame = [_tf_password frame];
        frame.origin.x = 20;
        frame.size.width = width - 40;
        [_tf_password setFrame:frame];
        frame = [_result frame];
        frame.origin.x = 20;
        frame.size.width = width - 40;
        [_result setFrame:frame];
        frame = [_check frame];
        frame.origin.x = 20;
        frame.size.width = (width - 50) / 2;
        [_check setFrame:frame];
        frame = [_create frame];
        frame.origin.x = 20 + (width - 40)/2;
        frame.size.width = (width - 50) / 2;
        [_create setFrame:frame];
        frame = [_done frame];
        frame.origin.x = 20;
        frame.size.width = (width - 50) / 2;
        [_done setFrame:frame];
        frame = [_save frame];
        frame.origin.x = 20 + (width - 40)/2;
        frame.size.width = (width - 50) / 2;
        [_save setFrame:frame];
    }
    
    [_check.layer setCornerRadius:7.0f];
    //[_check.layer setClipToBounds:YES];

    [_done.layer setCornerRadius:7.0f];
    [_save.layer setCornerRadius:7.0f];
    //[_done.layer setClipToBounds:YES];
    
    [_create.layer setCornerRadius:7.0f];
    //[_create.layer setClipToBounds:YES];
    
}


@end
