/**********************************************************
 UserPrefs.m

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


#import "UserPrefs.h"

@implementation UserPrefs

- (void) setUserId:(NSString *)user_id
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:user_id forKey:@"User email"];
    [prefs synchronize];
}

- (NSString *)getUserId
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString *uid = [prefs stringForKey:@"User email"];
    if (uid == nil) { uid = @""; }
    return uid;
}

- (BOOL) hasUserId
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString *uid = [prefs stringForKey:@"User email"];
    if (uid == nil) { return FALSE; } else { return TRUE; }
}

- (void) setPassword:(NSString *)password
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:password forKey:@"User password"];
    [prefs synchronize];
}

- (NSString *)getPassword
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString *passwd = [prefs stringForKey:@"User password"];
    if (passwd == nil) { passwd = @""; }
    return passwd;
}


@end
