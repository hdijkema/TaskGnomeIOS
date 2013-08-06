/**********************************************************************
 TaskGnomeAppDelegate.m
 
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


#import "TaskGnomeAppDelegate.h"


@interface TaskGnomeAppDelegate()

- (NSURL *) tasksDocumentDirectory;

@property (nonatomic, strong) NSManagedObjectModel *myManagedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *myPersistentStoreCoordinator;

@end

@implementation TaskGnomeAppDelegate

@synthesize cd_delegate = _cd_delegate;
@synthesize taskSelector = _taskSelector;
@synthesize myManagedObjectModel=_managedObjectModel,
            myPersistentStoreCoordinator=_persistentStoreCoordinator;

@synthesize window = _window;

- (void)setTaskSelector:(TaskSelector *)ts
{
    _taskSelector = ts;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self cd_delegate];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [_cd_delegate saveContext];
    if (_taskSelector) {
        [_taskSelector stopSyncTimer];
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [_cd_delegate saveContext];
    if (_taskSelector) {
        [_taskSelector stopSyncTimer];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (_taskSelector) {
        [_taskSelector startSyncTimer];
        [_taskSelector triggerSync];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [_cd_delegate saveContext];
    if (_taskSelector) {
        [_taskSelector stopSyncTimer];
    }
}



- (CdDelegate *) cd_delegate
{
    if (_cd_delegate == nil) {
        _cd_delegate = [[CdDelegate alloc] init];
    }
    return _cd_delegate;
}

- (NSManagedObjectModel *) managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Test" withExtension:@"momd"];
    //_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self tasksDocumentsDirectory] URLByAppendingPathComponent:@"tasks.db"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSError *error;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)tasksDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
