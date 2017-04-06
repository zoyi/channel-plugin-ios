//
//  LoginViewController.m
//  Channel Plugin Sample objc
//
//  Created by Haeun Chung on 21/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"

@interface LoginViewController () <UITextFieldDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.idField.placeholder = @"user Id";
  self.usernameField.placeholder = @"user name (optional)";
  self.phoneField.placeholder = @"mobile number (optional)";
  self.warningLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickOnLogin {
  [self.idField resignFirstResponder];
  [self.phoneField resignFirstResponder];
  [self.usernameField resignFirstResponder];
  
  if (![self.idField.text isEqualToString:@""]) {
    self.warningLabel.text = @"";
    [self performSegueWithIdentifier:@"MainViewSegue" sender:nil];
  } else {
    self.warningLabel.text = @"id is required to login as user";
  }
}
  
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.idField resignFirstResponder];
  [self.phoneField resignFirstResponder];
  [self.usernameField resignFirstResponder];
  return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"MainViewSegue"]) {
    MainViewController *viewController = [segue destinationViewController];
    viewController.isUser = YES;
    viewController.userId = self.idField.text;
  }
}

@end
