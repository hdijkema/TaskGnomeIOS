/**********************************************************************
 TasksNavigationViewController.m
 
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


#import "TasksNavigationViewController.h"

@interface TasksNavigationViewController ()

@property (nonatomic, weak) TaskSelector * tasksSelector;
@property (nonatomic, weak) TasksViewController * tasksController;

@end


@implementation TasksNavigationViewController

@synthesize tasksSelector = _tasksSelector;
@synthesize tasksController = _tasksController;



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
    _tasksController = (TasksViewController *)[super topViewController];
    [_tasksSelector setTasksViewController:_tasksController];
    [_tasksController setTasksSelector:_tasksSelector];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTasksSelector:(TaskSelector *)taskSelector
{
    _tasksSelector = taskSelector;
}

/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TasksViewController * ctrl = (TasksViewController *) [segue destinationViewController];
    [_tasksSelector setTasksViewController:ctrl];
    [ctrl setTasksSelector:_tasksSelector];
}*/


@end
