/**********************************************************************
 UserAccountPanel.h
 
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


#import <UIKit/UIKit.h>

@interface UserAccountPanel : UIView

@property (nonatomic, weak) IBOutlet UITextField *user_email;
@property (nonatomic, weak) IBOutlet UITextField *tf_password;
@property (nonatomic, weak) IBOutlet UILabel *result;

@property (nonatomic, weak) IBOutlet UIButton *check;
@property (nonatomic, weak) IBOutlet UIButton *create;
@property (nonatomic, weak) IBOutlet UIButton *done;
@property (nonatomic, weak) IBOutlet UIButton *save;

- (void)setUserEmail:(NSString *)email;
- (NSString *)getUserEmail;

- (void)setPassword:(NSString *)password;
- (NSString *)getPassword;

- (void)setMessage:(NSString *)message;
- (void)setErrorMessage:(NSString *)message;

- (IBAction)handleTap:(id)sender;
- (void)dropKeyboard;

@end
