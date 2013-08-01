/**********************************************************
 CdTask+CdTaskExt.h
 
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


#import "CdTask.h"
#import "CdTaskMeta.h"

#define SECTION_TOO_LATE  0
#define SECTION_TODAY     1
#define SECTION_TOMORROW  2
#define SECTION_COMING_WEEK 3
#define SECTION_LATER     4

@interface CdTask (CdTaskExt)

- (CdTaskKind)getTaskKind;
- (void)setTaskKind:(CdTaskKind)kind;
- (void)updateSection;

@end
