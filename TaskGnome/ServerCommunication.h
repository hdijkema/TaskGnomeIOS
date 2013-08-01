/**********************************************************
 ServerCommunication.h
 
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
#import "CdDelegate.h"
#import "CdTask+CdTaskExt.h"
#import "IServerCOmmunication.h"

typedef enum {
    ceERROR,
    ceSUCCESS,
    ceOPEN_FOR_REGISTRATION
} cbCheckEnum;

@interface ServerCommunication : NSObject

- (ServerCommunication *) initWithUserAndCdDelegate:(NSString *)user password:(NSString *)pass delegate:(CdDelegate *)delegate;

typedef void (^cbSyncSuccess)(void);
typedef void (^cbSyncError)(NSString *message);

typedef void (^cbCheckResult)(NSString *message, cbCheckEnum code, int servercode);

- (void)synchronizeTasks:(NSObject<IServerCommunication> *)cb_context;

- (void) checkUserPass:(cbCheckResult)cb;
- (void) registerUserPass:(cbCheckResult)cb;

@end
