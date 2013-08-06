/**********************************************************
 CdDelegate.m
 
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

#import "CdDelegate.h"
#import "CdTask.h"
#import "CdCategory.h"
#import "CdDeletedTask.h"
#import "Md5.h"
#import "TaskGnomeAppDelegate.h"
#import "CdTask+CdTaskExt.h"

@interface CdDelegate()

@property int myCount;
@property NSFetchedResultsController *tasksController;
@property NSFetchedResultsController *tasksControllerFinished;
@property NSFetchedResultsController *catController;

@end

@implementation CdDelegate

static int counter = 0;

@synthesize managedObjectContext=_managedObjectContext;
@synthesize myCount = _myCount;
@synthesize tasksController = _tasksController;
@synthesize tasksControllerFinished = _tasksControllerFinished;
@synthesize catController = _catController;

NSError *myLastError;


- (Boolean) inError
{
    return myLastError != nil;
}

- (NSError *) theError
{
    return myLastError;
}

- (void) setIfError:(NSError *)error
{
    if (myLastError != nil) {
        // [myLastError dealloc]; seems not necessary with ARC?
    }
    if (error == nil) {
        myLastError = nil;
    } else {
        myLastError = [error copy];
    }
}

- (CdDelegate*)init
{
    self = [super init];
    
    NSManagedObjectContext* context = [self managedObjectContext];
    myLastError = nil;
    
    counter += 1;
    _myCount = counter;
    
    // If table of categories is empty, create it.
    int cat_count = [self countCategories];
    if (cat_count == 0) {
        CdCategory * cat = [self insertCategory:@"Inbox"];
        cat.cat_id = @"Inbox_id";
        cat = [self insertCategory:@"Personal"];
        cat.cat_id = @"Personal_id";
        cat = [self insertCategory:@"Work"];
        cat.cat_id = @"Work_id";
        [self saveContext];
    }
    if (cat_count < 4) {
        CdCategory * cat = [self insertCategory:@"-"];
        cat.cat_id = @"-";
        [self saveContext];
    }
    
    return self;
}

- (CdDelegate*)initMain
{
    self = [self init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    return self;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextDidSave:(NSNotification *)notification
{
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
    [_managedObjectContext performSelectorOnMainThread:selector withObject:notification waitUntilDone:YES];
}

- (void)setMd5Task:(CdTask *)task
{
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"yyyy-MM-dd"];
    NSString * dt = [form stringFromDate:[task due]];
    CdCategory *cat = [task cat_relation];
    NSString * cat_id = [cat cat_id];
    if (cat_id == nil) { cat_id = @""; }
    NSString * s = [NSString stringWithFormat: @"%@%@%@%@%@%@",[task name],cat_id,dt,[task more_info],[task priority],[task kind]];
    NSString *md5 = [s Md5];
    //NSLog(@"md5calc: '%@' : %@", s, md5);
    [task setMd5:md5];
    [task setUpdated:@"T"];
}	

- (BOOL)taskIsDeleted:(NSString *)task_id
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(task_id = %@)",task_id];
    [request setPredicate:predicate];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"CdDeletedTask" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *entities = [_managedObjectContext executeFetchRequest:request error:&error];
    if (entities == nil) {
        NSLog(@"%@", error	);
        return FALSE;
    } else {
        if ([entities count] == 0) {
            return FALSE;
        } else {
            return TRUE;
        }
    }
}

- (void)deleteTask:(NSString *)task_id
{
    CdTask *task = [self fetchTask:task_id];
    if (task != nil) {
        NSString *task_id = [task task_id];
        [_managedObjectContext deleteObject:task];
        CdDeletedTask *dtask = (CdDeletedTask *) [NSEntityDescription
                                                    insertNewObjectForEntityForName:@"CdDeletedTask"
                                                    inManagedObjectContext:_managedObjectContext];
        [dtask setTask_id:task_id];
        [self saveContext];
    } else {
        CdDeletedTask *dtask = (CdDeletedTask *) [NSEntityDescription
                                                  insertNewObjectForEntityForName:@"CdDeletedTask"
                                                  inManagedObjectContext:_managedObjectContext];
        [dtask setTask_id:task_id];
        [self saveContext];
    }
}

- (BOOL)taskExists:(NSString *)task_id
{
    CdTask *task = [self fetchTask:task_id];
    return task != nil;
}

- (NSString *)taskMd5:(NSString *)task_id
{
    CdTask *task = [self fetchTask:task_id];
    if (task == nil) {
        return @"";
    } else {
        return [task md5];
    }
}

- (BOOL)taskIsUpdated:(NSString *)task_id
{
    CdTask *task = [self fetchTask:task_id];
    if (task == nil) {
        return FALSE;
    } else {
        return [[task updated] isEqualToString:@"T"];
    }
}

- (void)setTaskIsUpdatedOnServer:(CdTask *)task
{
    task.updated = @"F";
    [self saveContext];
}

- (CdTask *)fetchTask:(NSString *)task_id
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(task_id = %@)",task_id];
    [request setPredicate:predicate];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"CdTask" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *entities = [_managedObjectContext executeFetchRequest:request error:&error];
    if (entities == nil) {
        NSLog(@"%@", error	);
        return nil;
    } else {
        if ([entities count] == 0) {
            NSLog(@"Task id %@ not found", task_id);
            return nil;
        } else {
            return (CdTask *) [entities objectAtIndex:0];
        }
    }
}

- (CdCategory *)fetchCategory:(NSString *)cat_id
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(cat_id = %@)",cat_id];
    [request setPredicate:predicate];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"CdCategory" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *entities = [_managedObjectContext executeFetchRequest:request error:&error];
    if (entities == nil) {
        NSLog(@"%@", error	);
        return nil;
    } else {
        if ([entities count] == 0) {
            NSLog(@"Category id %@ not found", cat_id);
            return nil;
        } else {
            return (CdCategory *) [entities objectAtIndex:0];
        }
    }
    
}


- (void)setMd5Category:(CdCategory *)category
{
    [category setMd5:[category name]];
}

- (CdTask *)newTask
{
    CdTask* task = (CdTask *) [NSEntityDescription
                               insertNewObjectForEntityForName:@"CdTask"
                               inManagedObjectContext:_managedObjectContext];
    NSUUID * uuid = [[NSUUID alloc] init];
    [task setTask_id:[uuid UUIDString]];
    CdCategory *cat = [self fetchCategory:@"-"];
    [task setCat_relation:cat];
    return task;
}

- (void)saveTask:(CdTask *)task
{
    [self setMd5Task:task];
    [self saveContext];
    [task updateSection];
}

- (void)saveTaskFromServer:(CdTask *)task
{
    [self setMd5Task:task];
    task.updated = @"F";
    [self saveContext];
    [task updateSection];
}

- (NSFetchedResultsController *) tasks:(CdTaskKind)kind
{
    NSFetchedResultsController *controller;
    
    if (_tasksController == nil) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        BOOL asc = YES; //(kind == Active) ? YES : NO;
        
        NSSortDescriptor *sortDescriptorDue = [[NSSortDescriptor alloc] initWithKey:@"due" ascending:asc];
        NSSortDescriptor *sortDescriptorPrio = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
        NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        //NSSortDescriptor *sortDescriptorSection = [[NSSortDescriptor alloc] initWithKey:@"task_section" ascending:YES];
        //NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorSection,sortDescriptorDue, nil];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorDue, sortDescriptorPrio, sortDescriptorName, nil];
        [request setSortDescriptors:sortDescriptors];
        
        CdTaskKind mykind = Active;
        NSNumber * k = [[NSNumber alloc] initWithInt:mykind];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(kind = %@)",k];
        [request setPredicate:predicate];
        
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"CdTask" inManagedObjectContext:_managedObjectContext];
        [request setEntity:entityDescription];
        
        NSString *cache_name = [[NSString alloc] initWithFormat:@"tasks_cache_%d", _myCount];
    	
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                                  initWithFetchRequest:request
                                                  managedObjectContext:_managedObjectContext
                                                  sectionNameKeyPath:@"task_section"
                                                  cacheName:nil];
        
        _tasksController = controller;
        
        {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            
            BOOL asc = NO; //(kind == Active) ? YES : NO;
            
            NSSortDescriptor *sortDescriptorDue = [[NSSortDescriptor alloc] initWithKey:@"due" ascending:asc];
            NSSortDescriptor *sortDescriptorPrio = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
            NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            //NSSortDescriptor *sortDescriptorSection = [[NSSortDescriptor alloc] initWithKey:@"task_section" ascending:YES];
            //NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorSection,sortDescriptorDue, nil];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorDue, sortDescriptorPrio, sortDescriptorName, nil];
            [request setSortDescriptors:sortDescriptors];
            
            CdTaskKind mykind = Finished;
            NSNumber * k = [[NSNumber alloc] initWithInt:mykind];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(kind = %@)",k];
            [request setPredicate:predicate];
            
            NSEntityDescription *entityDescription = [NSEntityDescription
                                                      entityForName:@"CdTask" inManagedObjectContext:_managedObjectContext];
            [request setEntity:entityDescription];
            
            NSString *cache_name = [[NSString alloc] initWithFormat:@"tasks_cache_%d", _myCount];
            
            NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                                      initWithFetchRequest:request
                                                      managedObjectContext:_managedObjectContext
                                                      sectionNameKeyPath:@"task_section"
                                                      cacheName:nil];
            
            _tasksControllerFinished = controller;
        }
        
    } 

    if (kind == Active) {
        controller = _tasksController;
    } else {
        controller = _tasksControllerFinished;
    }
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSError *error = nil;
    BOOL success = [controller performFetch:&error];
    [self setIfError:error];
    NSLog(@"tasks: succes %d, error %@", success, error);
    
    return controller;
}

- (NSDictionary *)getTaskIds
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"CdTask" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entityDescription];
    
    NSMutableDictionary *ids = [[NSMutableDictionary alloc] init];
    NSError *error = nil;
    NSArray *entities = [_managedObjectContext executeFetchRequest:request error:&error];
    if (entities == nil) {
        NSLog(@"%@", error	);
        return ids;
    } else {
        [entities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CdTask *task = (CdTask *) obj;
            NSString *task_id = [task task_id];
            NSString *md5 = [task md5];
            [ids setObject:md5 forKey:task_id];
        }];
        return ids;
    }
}

- (NSDictionary *)getDeletedTaskIds
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"CdDeletedTask" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entityDescription];
    
    NSMutableDictionary *ids = [[NSMutableDictionary alloc] init];
    NSError *error = nil;
    NSArray *entities = [_managedObjectContext executeFetchRequest:request error:&error];
    if (entities == nil) {
        NSLog(@"%@", error	);
        return ids;
    } else {
        [entities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CdDeletedTask *task = (CdDeletedTask *) obj;
            NSString *task_id = [task task_id];
            NSString *md5 = @"";
            [ids setObject:md5 forKey:task_id];
        }];
        return ids;
    }
}

- (CdCategory *)insertCategory:(NSString *)category
{
    CdCategory* cat = (CdCategory *) [NSEntityDescription
                                        insertNewObjectForEntityForName:@"CdCategory"
                                        inManagedObjectContext:_managedObjectContext];
    NSUUID * uuid = [[NSUUID alloc] init];

    [cat setName:category];
    [cat setCat_id:[uuid UUIDString]];
    [self setMd5Category:cat];
    return cat;
}

- (NSFetchedResultsController *) categories
{
    NSFetchedResultsController * controller;
    
    if (_catController == nil) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        //[sortDescriptors release];  This should not be necessary anymore because of ARC feature
        //[sortDescriptor release];
        
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"CdCategory" inManagedObjectContext:_managedObjectContext];
        [request setEntity:entityDescription];
        
        NSString *cache_name = [[NSString alloc] initWithFormat:@"category_cache_%d", _myCount];
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                                  initWithFetchRequest:request
                                                  managedObjectContext:_managedObjectContext
                                                  sectionNameKeyPath:nil
                                                  cacheName:nil];
        
        _catController = controller;
    } else {
        controller = _catController;
    }
    
    NSError *error = nil;
    BOOL success = [controller performFetch:&error];
    [self setIfError:error];
    
    return controller;
}

- (int) countCategories
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CdCategory" inManagedObjectContext:self.managedObjectContext]];
    
    NSError* error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
    [self setIfError:error];
    
    if(count == NSNotFound) {
        //TODO: Set error in this object.
        return -1;
    } else {
        return count;
    }
}


- (void)saveContext
{
    NSError *error;
    if (_managedObjectContext != nil) {
        BOOL changes = [_managedObjectContext hasChanges];
        if (changes && ![_managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
            // Helaas dan
        }
    }
}

- (void)rollBack
{
    [_managedObjectContext undo];
}

- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
        [_managedObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
    }
    return _managedObjectContext;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    UIApplication *myApplication = [UIApplication sharedApplication];
    TaskGnomeAppDelegate *appDelegate = (TaskGnomeAppDelegate *) myApplication.delegate;
    return [appDelegate managedObjectModel];
}


/*
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    UIApplication *myApplication = [UIApplication sharedApplication];
    TaskGnomeAppDelegate *appDelegate = (TaskGnomeAppDelegate *) myApplication.delegate;
    return [appDelegate persistentStoreCoordinator];
}


@end
