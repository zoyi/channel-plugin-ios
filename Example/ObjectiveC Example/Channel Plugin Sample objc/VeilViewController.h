//
//  MainViewController.h
//  Channel Plugin Sample objc
//
//  Created by Haeun Chung on 21/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VeilViewController : UIViewController
@property (weak) IBOutlet UITextField *pluginKeyField;

@property (weak) IBOutlet UIButton *bootButton;
@property (weak) IBOutlet UIButton *shutdownButton;

@property (weak) IBOutlet UIButton *showLauncherButton;
@property (weak) IBOutlet UIButton *hideLauncherButton;
@property (weak) IBOutlet UIButton *openChatButton;
@end
