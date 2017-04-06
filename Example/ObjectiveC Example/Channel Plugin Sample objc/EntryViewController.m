//
//  EntryViewController.m
//  Channel Plugin Sample objc
//
//  Created by Haeun Chung on 21/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import "EntryViewController.h"
#import "MainViewController.h"

@interface EntryViewController ()

@end

@implementation EntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"MainViewSegue"]) {
    MainViewController *viewController = [segue destinationViewController];
    viewController.isUser = false;
  }
}
@end
