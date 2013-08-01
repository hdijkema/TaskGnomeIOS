//
//  TestAppDelegate.h
//  Test
//
//  Created by Lion User on 09/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CdDelegate.h"

@interface TaskGnomeAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) CdDelegate* cd_delegate;

- (NSManagedObjectModel *) managedObjectModel;
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator;
 
@end
