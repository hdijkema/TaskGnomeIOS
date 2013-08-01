/**********************************************************************
 AddTaskDialog.m
 
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


#import "AddTaskDialog.h"
#import "ChooseCategoryDialog.h"
#import "ChoosePriorityDialog.h"
#import "LabelDialog.h"
#import "Util.h"
#import "ActionSheetPicker.h"
#import "SwitchCell.h"
#import "TextViewCell.h"

@interface AddTaskDialog ()

@property (nonatomic, weak) IBOutlet UILabel *tcName;
@property (nonatomic, weak) IBOutlet UILabel *tcCategory;
@property (nonatomic, weak) IBOutlet UILabel *tcDate;
@property (nonatomic, weak) IBOutlet UILabel *tcPriority;
@property (nonatomic, weak) IBOutlet UITextField *tfName;
@property (nonatomic, weak) IBOutlet UISegmentedControl *scPriority;
@property (nonatomic, weak) IBOutlet UITextField *tfDate;
@property (nonatomic, weak) IBOutlet TextViewCell *tvcMoreInfo;
@property (nonatomic, weak) IBOutlet SwitchCell *swFinished;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelButton;

@property (nonatomic, strong) AbstractActionSheetPicker *actionSheetPicker;
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) NSString *myName;

@property (nonatomic, weak) CdCategory *category;

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element;

- (IBAction)save:(id)sender;
- (IBAction)done:(id)sender;

@end

#define NAME_CELL_ROW       0
#define PRIORITY_CELL_ROW   1
#define DATE_CELL_ROW       2
#define CATEGORY_CELL_ROW   3

#define EDIT_MODE           1
#define ADD_MODE            2

@implementation AddTaskDialog

__weak TasksViewController      *ovc;
UIDatePicker                    *datePicker;

@synthesize actionSheetPicker   = _actionSheetPicker;
@synthesize selectedDate        = _selectedDate;
@synthesize category            = _category;
@synthesize swFinished          = _swFinished;
@synthesize tvcMoreInfo         = _tvcMoreInfo;
@synthesize toolbar             = _toolbar;
@synthesize saveButton          = _saveButton;
@synthesize cancelButton        = _cancelButton;
@synthesize myName              = _myName;

int use_mode = ADD_MODE;


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
    
    _selectedDate = [[NSDate alloc] init];

    if (use_mode == ADD_MODE) {
        [self setCat:@"-"];
        [self setDue:_selectedDate];
        [self setName:@""];
        [self setPriority:0];
        [self setKind:Active];
        [self setMoreInfo:@""];
    } else {
        [ovc prepareForEditTask:self];
    }
}

- (void)setParent:(TasksViewController *)p
{
    ovc = p;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Dialog Getters and Setters & ICdTaskInfo protocol implementation
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setCat:(NSString *)c
{
    self.tcCategory.text = c;
}

- (void)setDue:(NSDate *)dt
{
    self.tcDate.text = [self formatDate:dt];
}

- (void) setPriority:(int)p
{
    if (p > 4) { p = 0; }	
    if (IPHONE) {
        if (p == 0) {
            self.tcPriority.text = @"-";
        } else {
            self.tcPriority.text = [NSString stringWithFormat:@"%d", p];
        }
    } else {
        self.scPriority.selectedSegmentIndex = p;
    }
}

- (void) setName:(NSString *)n
{
    if (IPHONE) {
        _myName = n;
        if ([n isEqualToString:@""]) {
            n = @"-";
        }
        self.tcName.text = n;
    } else {
        _myName = n;
        self.tfName.text = n;
    }
}

- (void)setCategory:(CdCategory *)category
{
    _category = category;
    if (_category) {
        [self setCat:_category.name];
    } else {
        [self setCat:@"-"];
    }
}

- (void)setMoreInfo:(NSString *)info
{
    [_tvcMoreInfo setViewText:info];
}

- (void) setKind:(CdTaskKind)kind
{
    [_swFinished setSwitch:(kind == Finished) ? YES : NO];
}


- (NSString *)getCat
{
    return self.tcCategory.text;
}

- (NSDate *)getDue
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *myDate = [df dateFromString:self.tcDate.text];
    return myDate;
}

- (int) getPriority
{
    int R;
    if (IPHONE) {
        R = [self.tcPriority.text intValue];
    } else {
        R = self.scPriority.selectedSegmentIndex;
    }
    if (R < 1) { R = 9; }
    return R;
}

- (NSString *)getName
{
    return _myName;
/*    if (IPHONE) {
        return _myName;
    } else {
        return self.tfName.text;
    }*/
}

- (CdCategory *)getCategory
{
    return _category;
}

- (NSString *)getMoreInfo
{
    return [_tvcMoreInfo getViewText];
}


- (CdTaskKind)getKind
{
    CdTaskKind kind = ([_swFinished getSwitch]) ? Finished : Active;
    return kind;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interaction with the task view controller
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)save:(id)sender
{
    if (use_mode == ADD_MODE) {
        [ovc addTask:self];
    } else {
        [ovc updateTask:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAddMode
{
    use_mode = ADD_MODE;
}

- (void)setEditMode
{
    use_mode = EDIT_MODE;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Supportive functions
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)formatDate:(NSDate *)dt
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString  = [df stringFromDate:dt];
    return dateString;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interaction with Sub Dialogs
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    _selectedDate = selectedDate;
    _tcDate.text = [self formatDate:_selectedDate];
}

- (IBAction)pickDate:(id)sender
{
    _selectedDate = [self getDue];
    _actionSheetPicker = [[ActionSheetDatePicker alloc]
                             initWithTitle:@"" datePickerMode:UIDatePickerModeDate
                             selectedDate:self.selectedDate
                             target:self action:@selector(dateWasSelected:element:)
                             origin:sender
                          ];
    [self.actionSheetPicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
    self.actionSheetPicker.hideCancel = YES;
    [self.actionSheetPicker showActionSheetPicker];
    
}

- (void)setLabel:(NSString *)str
{
    self.tcName.text = str;
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    if (row == DATE_CELL_ROW) {
        [self pickDate:self.view];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"sgGetCategoryIPhone"]) {
        ChooseCategoryDialog *dlg = (ChooseCategoryDialog *) [segue destinationViewController];
        [dlg setDelegate:self popover:nil];
    } else if ([segue.identifier isEqualToString:@"sgGetCategoryIPad"]) {
        ChooseCategoryDialog *dlg = (ChooseCategoryDialog *) [segue destinationViewController];
        UIPopoverController *ctrl = [(UIStoryboardPopoverSegue *) segue popoverController];
        [dlg setDelegate:self popover:ctrl];
    } else if ([segue.identifier isEqualToString:@"sgGetNameIPhone"]) {
        LabelDialog *dlg = (LabelDialog *) [segue destinationViewController];
        [dlg setHint:@"Name"];
        [dlg setText:[self getName]];
        [dlg setLabelTitle:@"Enter taskname"];
        [dlg setCallback:^(NSString *n) { [self setName:n]; } ];        // CLOSURES!
    } else if ([segue.identifier isEqualToString:@"sgGetPriorityIPhone"]) {
        ChoosePriorityDialog *dlg = (ChoosePriorityDialog *) [segue destinationViewController];
        [dlg setDelegate:self];
        [dlg setCurrentPriority:[self getPriority]];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interaction with table
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
    //return [super numberofRowsInSection](section);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


// Override to support conditional editing of the table view.
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
    if (indexPath.row == NAME_CELL_ROW) {
        return YES;
    } else {
        return NO;
    }
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
