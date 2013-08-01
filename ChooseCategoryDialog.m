/**********************************************************************
 ChooseCategoryDialog.m
 
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


#import "ChooseCategoryDialog.h"
#import "TaskGnomeAppDelegate.h"
#import "CdCategory.h"

@interface ChooseCategoryDialog ()

@end

@implementation ChooseCategoryDialog

NSFetchedResultsController *fetchedCategories;
AddTaskDialog *delegate;
NSString *kind;
id popover;

- (void)setDelegate:(AddTaskDialog *)dg popover:(id)ppvr
{
    delegate = dg;
    popover = ppvr;
}

- (void)awakeFromNib
{
    if (self) {
        [self initSelf];
    }
}

- (void)initSelf
{
    // Custom initialization
    UIApplication *myApplication = [UIApplication sharedApplication];
    TaskGnomeAppDelegate *appDelegate = (TaskGnomeAppDelegate *) myApplication.delegate;
    fetchedCategories = [[appDelegate cd_delegate] categories];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int N = [[fetchedCategories sections] count];
    return N;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedCategories sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    /*if (section == 0) {
        int N = [[fetchedCategories fetchedObjects] count];
        return N;
    } else {
        return 0;
    }*/
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    int row = indexPath.row;
    
    CdCategory *cat = (CdCategory *) [[fetchedCategories fetchedObjects] objectAtIndex:row];
    [[cell textLabel] setText:[cat name]];
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedCategories sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (IBAction)setCategory:(id)sender
{
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    int row = indexPath.row;
    CdCategory *cat = (CdCategory *) [[fetchedCategories fetchedObjects] objectAtIndex:row];
    [delegate setCategory:cat];

    if (popover != nil) {
        [(UIPopoverController *) popover dismissPopoverAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
