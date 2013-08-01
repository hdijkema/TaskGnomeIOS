/**********************************************************************
 TaskSelector.m
 
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


#ifndef __TASKSELECTOR__
#define __TASKSELECTOR__

#import <UIKit/UIKit.h>
#import "TasksViewController.h"
#import "TaskSelector.h"
#import "IServerCommunication.h"
#import "ServerCommunication.h"
#import "CdTaskMeta.h"

@interface TaskSelector : UIViewController <UITabBarDelegate, IServerCommunication>

@property (nonatomic, weak) IBOutlet TasksViewController * taskview;
@property (nonatomic, weak) IBOutlet UITabBarItem * active_tasks;
@property (nonatomic, weak) IBOutlet UITabBarItem * finished_tasks;
@property (nonatomic, weak) IBOutlet UITabBarItem * preferences;

- (void)setTasksViewController:(TasksViewController *)c;

- (CdTaskKind) activeViewKind;

- (ServerCommunication *)checkUserPass:(NSString *)user password:(NSString *)password waiter:(cbCheckResult)cb;
- (ServerCommunication *)registerUserPass:(NSString *)user password:(NSString *)password waiter:(cbCheckResult)cb;
- (void)triggerSync;
- (void)checkConnection;

@end

#endif