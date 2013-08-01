/**********************************************************************
 CdTask.h
 
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


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CdCategory;

@interface CdTask : NSManagedObject

@property (nonatomic, retain) NSDate * due;
@property (nonatomic, retain) NSNumber * kind;
@property (nonatomic, retain) NSString * md5;
@property (nonatomic, retain) NSString * more_info;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * task_id;
@property (nonatomic, retain) NSNumber * task_section;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) CdCategory *cat_relation;

@end
