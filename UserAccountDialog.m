/**********************************************************************
 UserAccountDialog.m
 
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


#import "UserAccountDialog.h"
#import "TaskSelector.h"
#import "UserAccountPanel.h"
#import "ServerCommunication.h"
#import "UserPrefs.h"

@interface UserAccountDialog ()

@property (nonatomic, weak) TaskSelector *selector;
@property (nonatomic, strong) ServerCommunication *sc;

@end

@implementation UserAccountDialog

@synthesize selector = _selector;
@synthesize sc = _sc;

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
	// Do any additional setup after loading the view.
    
    UserPrefs *prefs = [[UserPrefs alloc] init];
    UserAccountPanel *ua_panel = (UserAccountPanel *) self.view;
    [ua_panel setUserEmail:[prefs getUserId]];
    [ua_panel setPassword:[prefs getPassword]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTasksSelector:(TaskSelector *)ts
{
    _selector = ts;
}

- (IBAction)check:(id)sender
{
    UserAccountPanel *ua_panel = (UserAccountPanel *) self.view;
    if (_sc == nil) {
        [ua_panel dropKeyboard];
        _sc = [_selector checkUserPass:[ua_panel getUserEmail] password:[ua_panel getPassword]
                                waiter:^(NSString *msg, cbCheckEnum code, int nr) {
            UserAccountPanel *ua_panel = (UserAccountPanel *) self.view;
            if (code == ceSUCCESS || code == ceOPEN_FOR_REGISTRATION) {
                [ua_panel setMessage:msg];
                _sc = nil;
            } else {
                [ua_panel setErrorMessage:msg];
                _sc = nil;
            }
            /*if (code == ceSUCCESS) {
                UserPrefs *prefs = [[UserPrefs alloc] init];
                [prefs setUserId:[ua_panel getUserEmail]];
                [prefs setPassword:[ua_panel getPassword]];
            }*/
        }];
    } else {
        [ua_panel setErrorMessage:@"Busy checking server"];
    }
}

- (IBAction)create:(id)sender
{
    UserAccountPanel *ua_panel = (UserAccountPanel *) self.view;
    if (_sc == nil) {
        [ua_panel dropKeyboard];
        _sc = [_selector registerUserPass:[ua_panel getUserEmail] password:[ua_panel getPassword]
                                   waiter:^(NSString *msg, cbCheckEnum code, int nr) {
            UserAccountPanel *ua_panel = (UserAccountPanel *) self.view;
            if (code == ceSUCCESS || code == ceOPEN_FOR_REGISTRATION) {
                [ua_panel setMessage:msg];
                _sc = nil;
            } else {
                [ua_panel setErrorMessage:msg];
                _sc = nil;
            }
            /*if (code == ceSUCCESS) {
                UserPrefs *prefs = [[UserPrefs alloc] init];
                [prefs setUserId:[ua_panel getUserEmail]];
                [prefs setPassword:[ua_panel getPassword]];
            }*/
        }];
    } else {
        [ua_panel setErrorMessage:@"Busy checking server"];
    }
}

- (IBAction)done:(id)sender
{
    [_selector triggerSync];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender
{
    UserAccountPanel *ua_panel = (UserAccountPanel *) self.view;
    
    UserPrefs *prefs = [[UserPrefs alloc] init];
    NSString * um = [ua_panel getUserEmail];
    um = [um stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [prefs setUserId:um];
    [prefs setPassword:[ua_panel getPassword]];
    
    [_selector checkConnection];
    [_selector triggerSync];
    [self dismissViewControllerAnimated:YES completion:nil];
}





@end
