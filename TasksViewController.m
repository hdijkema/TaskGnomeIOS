/**********************************************************************
 TasksViewController.m
 
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


#import "TasksViewController.h"
#import "TaskGnomeAppDelegate.h"
#import "AddTaskDialog.h"
#import "CdTaskMeta.h"
#import "TaskTableCell.h"
#import "TaskSelector.h"
#import "Util.h"
#import "CdTask+CdTaskExt.h"
#import "UserPrefs.h"

@interface TasksViewController ()

@property (nonatomic, weak) TaskSelector *taskSelector;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnCheck;
@property (nonatomic, weak) IBOutlet UINavigationItem *bar;

@end

@implementation TasksViewController

//__weak UIPopoverController* addTaskPopover;
__weak CdDelegate           *cd_delegate;
NSFetchedResultsController  *fetchedTasks;
CdTaskKind                  _kind;

int action;
int editIndex;
int editSection;

#define SG_NONE      0
#define SG_ADD_TASK  1
#define SG_EDIT_TASK 2

@synthesize taskSelector = _taskSelector;
@synthesize btnCheck = _btnCheck;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Initialize stuff
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UIApplication *myApplication = [UIApplication sharedApplication];
    TaskGnomeAppDelegate *appDelegate = (TaskGnomeAppDelegate *) myApplication.delegate;
    cd_delegate = [appDelegate cd_delegate];
    _kind = Active;
    
    [self checkConnection];
    [self fetchTasks];
    
    action = SG_NONE;
}

- (void)checkConnection
{
    if (_taskSelector) {
        UserPrefs * prefs = [[UserPrefs alloc] init];
        NSString * user = [prefs getUserId];
        NSString * pass = [prefs getPassword];
        if (user != nil && ![user isEqualToString:@""]) {
            [_taskSelector checkUserPass:user password:pass waiter:^(NSString *message, cbCheckEnum code, int nr) {
                if (code == ceERROR || code==ceOPEN_FOR_REGISTRATION) {
                    if (nr == 701) {
                        message = @"Wrong password - setup account";
                    } else if (nr == 750) {
                        message = @"subscription expired - visit website";
                    } else if (nr == 702) {
                        message = @"Wrong user - setup account";
                    } else {
                        // do nothing
                    }
                    _bar.prompt = message;
                } else {
                    _bar.prompt = nil;
                }
            }];
        } else {
            if (![prefs hasUserId]) {
                _bar.prompt = @"Please setup an account (maybe empty)";
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTasksSelector:(id)ts
{
    _taskSelector = (TaskSelector *) ts;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Data mutation and fetching
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (CdDelegate *) getCdDelegate
{
    return cd_delegate;
}

- (void) triggerSync
{
    [_taskSelector triggerSync];
}

- (void)addTask:(NSObject<ICdTaskInfo> *)info
{
    CdTask *task = [cd_delegate newTask];
    task.name = [info getName];
    task.more_info = [info getMoreInfo];
    task.due = [info getDue];
    task.cat_relation = [info getCategory];
    NSNumber *pp = [[NSNumber alloc] initWithInt:[info getPriority]];
    task.priority = pp;
    CdTaskKind kind = _kind;
    NSNumber *k = [[NSNumber alloc] initWithInt:kind];
    task.kind = k;
    [cd_delegate saveTask:task];
    [self fetchTasks];
    [[self tableView] reloadData];
    [self triggerSync];
}

- (void)updateTask:(NSObject<ICdTaskInfo> *)info
{
    id <NSFetchedResultsSectionInfo> theSection = [[fetchedTasks sections] objectAtIndex:editSection];
    NSArray *tasks = [theSection objects];
    CdTask *task = (CdTask *) [tasks objectAtIndex:editIndex];
    task.name = [info getName];
    task.more_info = [info getMoreInfo];
    task.due = [info getDue];
    task.cat_relation = [info getCategory];
    task.priority = [[NSNumber alloc] initWithInt:[info getPriority]];
    task.kind = [[NSNumber alloc] initWithInt:[info getKind]];
    [cd_delegate saveTask:task];
    [self fetchTasks];
    [[self tableView] reloadData];
    [self triggerSync];
}

- (void)finishTask:(CdTask *)task
{
    task.kind = [[NSNumber alloc] initWithInt:Finished];
    [cd_delegate saveTask:task];
    [self fetchTasks];
    [[self tableView] reloadData];
    [self triggerSync];
}

- (void)activateTask:(CdTask *)task
{
    task.kind = [[NSNumber alloc] initWithInt:Active];
    [cd_delegate saveTask:task];
    [self fetchTasks];
    [[self tableView] reloadData];
    [self triggerSync];
}

- (void)refresh
{
    [self fetchTasks];
    [[self tableView] reloadData];
}

- (void) fetchTasks
{
    fetchedTasks = [cd_delegate tasks:_kind];
}

- (void)selectActiveTasks
{
    if (_kind != Active) {
        _kind = Active;
        _btnCheck.title = @"Check";
        [self fetchTasks];
        [[self tableView] reloadData];
    }
}

- (void)selectFinishedTasks
{
    if (_kind != Finished) {
        _kind = Finished;
        _btnCheck.title = @"Uncheck";
        [self fetchTasks];
        [[self tableView] reloadData];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Dialogs
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)dlgAddTask:(id)sender
{
    action = SG_ADD_TASK;
    if (IPHONE) {
        [self performSegueWithIdentifier:@"sgAddTaskiPhone" sender:sender];
    } else {
        [self performSegueWithIdentifier:@"sgAddTask" sender:sender];
    }
}

- (IBAction)checkTask:(id)sender
{
    NSIndexPath *path = [[self tableView] indexPathForSelectedRow];
    if (path) {
        editIndex = path.row;
        editSection = path.section;
        id <NSFetchedResultsSectionInfo> theSection = [[fetchedTasks sections] objectAtIndex:editSection];
        NSArray *tasks = [theSection objects];
        CdTask *task = (CdTask *) [tasks objectAtIndex:editIndex];
        if (_kind == Active) {
            [self finishTask:task];
        } else {
            [self activateTask:task];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    editIndex = indexPath.row;
    editSection = indexPath.section;
    action = SG_EDIT_TASK;
    if (IPHONE) {
        [self performSegueWithIdentifier:@"sgAddTaskiPhone" sender:self];
    } else {
        [self performSegueWithIdentifier:@"sgAddTask" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (action == SG_ADD_TASK) {
        AddTaskDialog *dlg;
        if (IPHONE) {
            UINavigationController *ctrl = [segue destinationViewController];
            dlg = [[ctrl viewControllers] objectAtIndex:0];
        } else {
            dlg = (AddTaskDialog *) [segue destinationViewController];
        }
        [dlg setParent:self];
        [dlg setAddMode];
        action = SG_NONE;
    } else if (action == SG_EDIT_TASK) {
        AddTaskDialog *dlg;
        if (IPHONE) {
            UINavigationController *ctrl = [segue destinationViewController];
            dlg = [[ctrl viewControllers] objectAtIndex:0];
        } else {
            dlg = (AddTaskDialog *) [segue destinationViewController];
        }
        [dlg setParent:self];
        [dlg setEditMode];
        action = SG_NONE;
    }
}

- (void)prepareForEditTask:(NSObject<ICdTaskInfo> *)info;
{
    id <NSFetchedResultsSectionInfo> theSection = [[fetchedTasks sections] objectAtIndex:editSection];
    NSArray *tasks = [theSection objects];
    CdTask *task = (CdTask *) [tasks objectAtIndex:editIndex];
    [info setName:[task name]];
    [info setCategory:[task cat_relation]];
    int p = [[task priority] intValue];
    [info setPriority:p];
    [info setDue:[task due]];
    CdTaskKind k = (CdTaskKind) [[task kind] intValue];
    [info setKind:k];
    [info setMoreInfo:[task more_info]];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Table stuff
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int N = [[fetchedTasks sections] count];
    return N;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedTasks sections] objectAtIndex:section];
    int N = [sectionInfo numberOfObjects];
    return N;
}

- (NSString *)getSectionName:(int)ts
{
    switch (ts) {
        case SECTION_TOO_LATE:
            return ([_taskSelector activeViewKind] == Active) ? @"Too late" : @"Past";
        case SECTION_TODAY:
            return @"Today";
        case SECTION_TOMORROW:
            return @"Tomorrow";
        case SECTION_COMING_WEEK:
            return @"Coming week";
        case SECTION_LATER:
            return @"Later";
        default:
            return @"Unknown";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int is = section;
    NSArray *st = [fetchedTasks sectionIndexTitles];
    NSNumber * n = [st objectAtIndex:is];
    is = [n intValue];
    NSString *sname = [self getSectionName:is];
    return sname;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    TaskTableCell *tcell = (TaskTableCell *) cell;
    
    int row = indexPath.row;
    int section = indexPath.section;
    id <NSFetchedResultsSectionInfo> theSection = [[fetchedTasks sections] objectAtIndex:section];
    NSArray *tasks = [theSection objects];
    CdTask *task = (CdTask *) [tasks objectAtIndex:row];
    

    NSArray *st = [fetchedTasks sectionIndexTitles];
    NSNumber * n = [st objectAtIndex:section];
    int is = [n intValue];
    if ([task getTaskKind] == Finished) {
        [tcell makeGrey];
    } else if (is == SECTION_TOO_LATE) {
        [tcell makeRed];
    } else if (is == SECTION_TODAY) {
        [tcell makeBlue];
    } else {
        [tcell makeBlack];
    }
    
    if (![[task more_info] isEqualToString:@""]) {
        [tcell makeMoreBackground];
    } else {
        [tcell makeStandardBackground];
    }

    [tcell setTaskName:[task name]];
    CdCategory *cat = [task cat_relation];
    if (cat == nil) {
        [tcell setCategoryName:@"-"];
    } else {	
        [tcell setCategoryName:[cat name]];
    }
    [tcell setDue:[task due]];
    NSNumber *np = [task priority];
    int p = [np intValue];
    [tcell setPriority:p];
    
    return tcell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        int section = indexPath.section;
        int row = indexPath.row;
        
        id <NSFetchedResultsSectionInfo> theSection = [[fetchedTasks sections] objectAtIndex:section];
        NSArray *tasks = [theSection objects];
        CdTask *task = (CdTask *) [tasks objectAtIndex:row];
        [cd_delegate deleteTask:[task task_id]];
        [self refresh];
        [self triggerSync];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
