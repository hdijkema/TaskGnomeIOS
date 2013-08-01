//
//  SwitchCell.h
//  TaskGnome
//
//  Created by Lion User on 17/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchCell : UITableViewCell

- (void)setTitle:(NSString *)title;
- (void)setSwitch:(BOOL)on;
- (void)preventLayout;

- (BOOL)getSwitch;

@end
