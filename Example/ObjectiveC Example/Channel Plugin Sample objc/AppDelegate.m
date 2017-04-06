//
//  AppDelegate.m
//  Channel Plugin Sample objc
//
//  Created by Haeun Chung on 21/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <CHPlugin/CHPlugin-Swift.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

#define ChannelAPIKey @"faa73a7c-4158-4a38-9a7a-793a969fd5bc"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self registerForRemoteNotification];
  
  [ChannelPlugin setDebugMode:YES];
  [ChannelPlugin initializeWithPluginKey:ChannelAPIKey];
  
  return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
  
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [ChannelPlugin registerWithDeviceToken:deviceToken];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
  NSDictionary *userInfo = response.notification.request.content.userInfo;
  [ChannelPlugin handlePushNotification:userInfo];
  
  completionHandler();
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  completionHandler(UIBackgroundFetchResultNewData);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  completionHandler(UNNotificationPresentationOptionSound|
                    UNNotificationPresentationOptionBadge|
                    UNNotificationPresentationOptionAlert);
}

- (void)registerForRemoteNotification {
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;
  [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|
                                          UNAuthorizationOptionBadge|
                                          UNAuthorizationOptionSound)
    completionHandler:^(BOOL granted, NSError * _Nullable error) {
      if (granted) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
      }
    }];
}

- (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
  const char *data = [deviceToken bytes];
  NSMutableString *token = [NSMutableString string];
  
  for (NSUInteger i = 0; i < [deviceToken length]; i++) {
    [token appendFormat:@"%02.2hhX", data[i]];
  }
  
  return [token copy];
}
  
@end
