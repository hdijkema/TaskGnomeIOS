/**********************************************************
 CdTask+CdTaskExt.m
 
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


#import "CdTask+CdTaskExt.h"

@implementation CdTask (CdTaskExt)

- (NSNumber *) toNumber:(int)x
{
    return [[NSNumber alloc] initWithInt:x];
}

- (void) updateSection
{
    [self awakeFromFetch];
}

- (void)awakeFromFetch
{
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    now = [dateFormat dateFromString:[dateFormat stringFromDate:now]];
    
    NSDate *due = [self due];
    if ([due compare:now] == NSOrderedAscending) {
        self.task_section = [self toNumber:SECTION_TOO_LATE];
    } else if ([due compare:now] == NSOrderedSame) {
        self.task_section = [self toNumber:SECTION_TODAY];
    } else {
        NSDate *tomorrow = [now dateByAddingTimeInterval:24*3600];
        if ([due compare:tomorrow] == NSOrderedSame) {
            self.task_section = [self toNumber:SECTION_TOMORROW];
        } else {
            NSDate *in_a_week = [now dateByAddingTimeInterval:24*3600*7];
            NSComparisonResult r = [due compare:in_a_week];
            if (r == NSOrderedAscending || r == NSOrderedSame) {
                self.task_section = [self toNumber:SECTION_COMING_WEEK];
            } else {
                self.task_section = [self toNumber:SECTION_LATER];
            }
        }
    }
}


- (void)awakeFromInsert
{
    [self awakeFromFetch];
}

- (void)awakeFromSnapshotEvents:(NSSnapshotEventType)flags
{
    [self awakeFromFetch];
}

- (CdTaskKind)getTaskKind
{
    NSNumber *k = [self kind];
    int x = [k intValue];
    return (CdTaskKind) x;
}

- (void)setTaskKind:(CdTaskKind)kind
{
    NSNumber *k = [[NSNumber alloc] initWithInt:(int) kind];
    self.kind = k;
//    [self setKind:k];
}


@end
