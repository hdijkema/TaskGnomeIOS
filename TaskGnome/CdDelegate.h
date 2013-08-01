/**********************************************************
 CdDelegate.h
 
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
 **********************************************************/

#import <Foundation/Foundation.h>
#import "CdTask.h"
#import "CdCategory.h"
#import "CdTaskMeta.h"

@interface CdDelegate : NSObject


@property (nonatomic) NSManagedObjectContext *managedObjectContext;

- (void) saveContext;
- (void) rollBack;


- (CdTask *) newTask;
- (void) saveTask:(CdTask *)task;
- (void) saveTaskFromServer:(CdTask *)task;


- (void)setMd5Task:(CdTask *)task;
- (void)setMd5Category:(CdCategory *)category;

- (BOOL)taskIsDeleted:(NSString *)task_id;
- (void)deleteTask:(NSString *)task_id;
- (BOOL)taskExists:(NSString *)task_id;
- (NSString *)taskMd5:(NSString *)task_id;
- (BOOL)taskIsUpdated:(NSString *)task_id;
- (CdTask *)fetchTask:(NSString *)task_id;

- (void)setTaskIsUpdatedOnServer:(CdTask *)task;

- (CdCategory *)insertCategory:(NSString *)category;
- (NSFetchedResultsController *) categories;
- (CdCategory *)fetchCategory:(NSString *)cat_id;

- (NSFetchedResultsController *) tasks:(CdTaskKind)kind;

- (NSDictionary *)getTaskIds;
- (NSDictionary *)getDeletedTaskIds;

- (Boolean) inError;
- (NSError *) theError;


@end

