//
//  TasksTableViewController.m
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/15/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import "TasksTableViewController.h"
#import "Phase.h"
#import "User.h"
#import "NetworkManager.h"
#import "TaskTableViewCell.h"
#import "PhaseHeaderView.h"
#import "Task.h"

@interface TasksTableViewController ()

@property (strong, nonatomic) Phase *phase;

@end

@implementation TasksTableViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NetworkManager manager] getTasksListForUser:self.user completion:^(Phase *phase) {
        if (phase) {
            self.phase = phase;
            PhaseHeaderView *headerView = (PhaseHeaderView *)self.tableView.tableHeaderView;
            headerView.phase = self.phase;
            headerView.avatarUrl = self.user.avatarImageUrl;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.phase.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TaskTableViewCell class]) forIndexPath:indexPath];
    
    cell.task = [self.phase.tasks objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskTableViewCell *cell = (TaskTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell animateReportImageView];
    
    Task *task = [self.phase.tasks objectAtIndex:indexPath.row];
    
    [[NetworkManager manager] reportTaskWithID:task.taskID forUser:self.user completion:^(BOOL success) {
        
    }];
}

@end
