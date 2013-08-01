//
//  UserAccountPanel.h
//  TaskGnome
//
//  Created by Lion User on 22/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

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
