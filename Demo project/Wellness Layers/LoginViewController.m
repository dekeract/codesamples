//
//  ViewController.m
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/14/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkManager.h"
#import "TasksTableViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginButton.layer.cornerRadius = 5;
}

- (IBAction)onLoginButtonTapped:(id)sender
{
    [self.activityIndicator startAnimating];
    [[NetworkManager manager] loginWithEmail:self.emailTextField.text andPass:self.passTextField.text completion:^(User *user) {
        if (user) {
            [self.activityIndicator stopAnimating];
            TasksTableViewController *tasksViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TasksTableViewController class])];
            tasksViewController.user = user;
            [self.navigationController pushViewController:tasksViewController animated:YES];
        } else {
            [self.activityIndicator stopAnimating];
            self.errorLabel.text = @"Failed to login";
        }
    }];
}

@end
