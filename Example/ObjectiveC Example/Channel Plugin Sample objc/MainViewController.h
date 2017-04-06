//
//  MainViewController.h
//  Channel Plugin Sample objc
//
//  Created by Haeun Chung on 21/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
@property (weak) IBOutlet UILabel *loginLabel;
@property (weak) IBOutlet UILabel *detailLabel;

@property (assign) BOOL isUser;
@property (assign) BOOL loaded;
@property (strong) NSString *userId;
@property (strong) NSString *userName;
@property (strong) NSString *phoneNumber;
@end
