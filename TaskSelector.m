/**********************************************************************
 TaskSelector.m
 
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


#import "TaskSelector.h"
#import "TasksNavigationViewController.h"
#import "ServerCommunication.h"
#import "UserPrefs.h"
#import "TaskGnomeAppDelegate.h"

@interface TaskSelector ()

@property (nonatomic, weak) IBOutlet UITabBar* bar;
@property BOOL syncing;
@property int currentView;
@property (nonatomic, strong) ServerCommunication *sc;

#define VIEW_ACTIVE_TASKS 1
#define VIEW_FINISHED_TASKS 2

#define SYNC_INTERVAL 20*60     // 20 minutes

@end

@implementation TaskSelector

@synthesize taskview = _taskview;
@synthesize active_tasks = _active_tasks;
@synthesize finished_tasks = _finished_tasks;
@synthesize preferences = _preferences;
@synthesize bar = _bar;
@synthesize sc = _sc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    UIApplication *myApplication = [UIApplication sharedApplication];
    TaskGnomeAppDelegate *appDelegate = (TaskGnomeAppDelegate *) myApplication.delegate;
    [appDelegate setTaskSelector:self];
    
    _bar.selectedItem = _active_tasks;
    self.currentView = VIEW_ACTIVE_TASKS;
    self.syncing = false;
    [self startSyncTimer];
    [self triggerSync];
}

- (void) startSyncTimer
{
    if (!self.syncing) {
        self.syncing = TRUE;
        NSTimer * syncer = [NSTimer scheduledTimerWithTimeInterval:SYNC_INTERVAL
                                                        target:self
                                                      selector:@selector(startSync:)
                                                      userInfo:nil
                                                       repeats:TRUE
                            ];
    }
}

-(void) stopSyncTimer
{
    self.syncing = FALSE;
}

- (void) startSync:(NSTimer *)watchSync
{
    if (self.syncing) {
        [self syncTasks];
    } else {
        [watchSync invalidate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    switch (item.tag) {
        case 0:
            [self selectActiveTasks];
            break;
        case 1:
            [self selectFinishedTasks];
            break;
        case 2:
            [self selectPreferences];
            break;
        case 3:
            [self selectAbout];
            break;
        default:
            break	;
            // does nothing
    }
}

- (void)setTasksViewController:(TasksViewController *)c
{
    _taskview = c;
}

- (void)selectActiveTasks
{
    self.currentView = VIEW_ACTIVE_TASKS;
    [_taskview selectActiveTasks];
}

- (void)selectFinishedTasks
{
    self.currentView = VIEW_FINISHED_TASKS;
    [_taskview selectFinishedTasks];
}

- (void) serverCommunicationOk
{
    NSLog(@"sco: OK!");
    [_taskview refresh];
    _sc = nil;
}

- (void) serverCommunicationError:(NSString *)message
{
    NSLog(@"sco: Error: %@", message);
    [_taskview refresh];
    _sc = nil;
}

- (void)triggerSync
{
    [self syncTasks];
}

- (void)syncTasks
{
    if (_sc == nil) {
        UserPrefs *prefs = [[UserPrefs alloc] init];
        NSString *user = [prefs getUserId];
        NSString *pass = [prefs getPassword];
        
        CdDelegate *dg = [[CdDelegate alloc] init];
        _sc = [[ServerCommunication alloc] initWithUserAndCdDelegate:user password:pass delegate:dg];
        [_sc synchronizeTasks:self];
    }
}

- (ServerCommunication *)checkUserPass:(NSString *)user password:(NSString *)password waiter:(cbCheckResult)cb
{
    CdDelegate *dg = [[CdDelegate alloc] init];
    ServerCommunication *sc = [[ServerCommunication alloc] initWithUserAndCdDelegate:user password:password delegate:dg];
    [sc checkUserPass:cb];
    return sc;
}

- (ServerCommunication *)registerUserPass:(NSString *)user password:(NSString *)password waiter:(cbCheckResult)cb
{
    CdDelegate *dg = [[CdDelegate alloc] init];
    ServerCommunication *sc = [[ServerCommunication alloc] initWithUserAndCdDelegate:user password:password delegate:dg];
    [sc registerUserPass:cb];
    return sc;
}

- (void) checkConnection
{
    [_taskview checkConnection];
}

- (void)selectPreferences
{
    [self performSegueWithIdentifier:@"sgUserAccountDialog" sender:self];
    if (self.currentView == VIEW_ACTIVE_TASKS) {
        _bar.selectedItem = _active_tasks;
    } else {
        _bar.selectedItem = _finished_tasks;
    }
}

- (void)selectAbout
{
    [self performSegueWithIdentifier:@"sgAboutDialog" sender:self];
    if (self.currentView == VIEW_ACTIVE_TASKS) {
        _bar.selectedItem = _active_tasks;
    } else {
        _bar.selectedItem = _finished_tasks;
    }
    
}

- (CdTaskKind) activeViewKind
{
    return (self.currentView == VIEW_ACTIVE_TASKS) ? Active : Finished;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TasksNavigationViewController * ctrl = (TasksNavigationViewController *) [segue destinationViewController];
    [ctrl setTasksSelector:self];
}

- (CdDelegate *) getCdDelegate
{
    return [_taskview getCdDelegate];
}


@end
