/**********************************************************************
 TasksViewController.h
 
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
#import "ICdTaskInfo.h"
#import "CdTaskMeta.h"
#import "CdDelegate.h"

@interface TasksViewController : UITableViewController

- (IBAction)dlgAddTask:(id)sender;
- (IBAction)checkTask:(id)sender;

- (void)addTask:(NSObject<ICdTaskInfo> *)info;
- (void)updateTask:(NSObject<ICdTaskInfo> *)info;

- (void)prepareForEditTask:(NSObject<ICdTaskInfo> *)task;

- (void)selectActiveTasks;
- (void)selectFinishedTasks;

- (void)refresh;

- (void)setTasksSelector:(id)ts;        // id must be of type TaskSelector *

- (CdDelegate *)getCdDelegate;

- (void)checkConnection;

@end
