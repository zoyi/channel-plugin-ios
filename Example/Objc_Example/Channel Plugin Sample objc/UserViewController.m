//
//  LoginViewController.m
//  Channel Plugin Sample objc
//
//  Created by Haeun Chung on 21/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import "UserViewController.h"
#import <ChannelIO/ChannelIO-Swift.h>

@interface UserViewController () <UITextFieldDelegate>

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pluginKeyField.placeholder = @"Insert your pluginKey";
    self.idField.placeholder = @"user Id";
    self.usernameField.placeholder = @"user name (optional)";
    self.phoneField.placeholder = @"mobile number (optional)";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.idField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    return YES;
}

- (IBAction)didClickOnBoot:(id)sender {
    [self.idField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.pluginKeyField resignFirstResponder];
    
    Profile *profile = [[Profile alloc] init];
    [profile setWithMobileNumber:self.phoneField.text];
    [profile setWithName:self.usernameField.text];

    ChannelPluginSettings *settings = [[ChannelPluginSettings alloc] init];
    [settings setPluginKey:self.pluginKeyField.text];
    [settings setUserId:self.idField.text];

    [ChannelIO bootWith:settings profile:profile completion:^(ChannelPluginCompletionStatus status, Guest *guest) {

    }];
}

- (IBAction)didClickOnShutdown:(id)sender {
    [ChannelIO shutdown];
}

- (IBAction)didClickOnShowLauncher:(id)sender {
    [ChannelIO showWithAnimated:YES];
}

- (IBAction)didClickOnHideLauncher:(id)sender {
    [ChannelIO hideWithAnimated:YES];
}

- (IBAction)didClickOnOpenChat:(id)sender {
    [ChannelIO openWithAnimated:YES];
}
@end
