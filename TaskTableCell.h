//
//  TaskTableCell.h
//  TaskGnome
//
//  Created by Lion User on 15/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskTableCell : UITableViewCell

- (void)setTaskName:(NSString*)name;
- (void)setCategoryName:(NSString*)cat_name;
- (void)setDue:(NSDate*)due;
- (void)setPriority:(int)priority;

- (void)adjustSizes:(int)width;

- (void)makeRed;
- (void)makeBlue;
- (void)makeGrey;
- (void)makeBlack;
- (void)makeMoreBackground;
- (void)makeStandardBackground;

@end
