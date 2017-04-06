//
//  LoginViewController.h
//  Channel Plugin Sample objc
//
//  Created by Haeun Chung on 21/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak) IBOutlet UITextField *idField;
@property (weak) IBOutlet UITextField *usernameField;
@property (weak) IBOutlet UITextField *phoneField;
@property (weak) IBOutlet UIButton *loginButton;
@property (weak) IBOutlet UILabel *warningLabel;
@end
