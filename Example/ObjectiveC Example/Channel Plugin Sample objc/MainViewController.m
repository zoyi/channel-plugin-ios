//
//  MainViewController.m
//  Channel Plugin Sample objc
//
//  Created by Haeun Chung on 21/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import "MainViewController.h"
#import <CHPlugin/CHPlugin-Swift.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  if (!self.loaded) {
    self.isUser ? [self loginAsUser] : [self loginAsVeil];
    self.loaded = YES;
  }
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  if (self.isMovingFromParentViewController) {
    [ChannelPlugin checkOut];
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginAsUser {
  if ([self.userId isEqualToString:@""]) {
    return;
  }
  
  CheckIn *checkin = [[CheckIn alloc] init];
  [checkin withName:@""];
  [checkin withUserId:self.userId];
  [checkin withMobileNumber:@""];
  
  [ChannelPlugin checkIn:checkin completion:^(enum ChannelCheckInCompletionStatus state) {
    switch (state) {
      case ChannelCheckInCompletionStatusSuccess:
        break;
      default:
        self.loginLabel.text = @"Login failed due to invalid parameters";
        self.detailLabel.text = @"Please go back and try again";
    }
  }];
}
  
- (void)loginAsVeil {
  [ChannelPlugin checkIn:nil completion:^(enum ChannelCheckInCompletionStatus state) {
    
  }];
}

@end
