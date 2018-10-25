//
//  AppDelegate.swift
//  Channel Plugin Sample
//
//  Created by Haeun Chung on 14/03/2017.
//  Copyright © 2017 Haeun Chung. All rights reserved.
//

import UIKit
import UserNotifications
import ChannelIO

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    registerForRemoteNotification(application)
    ChannelIO.initialize(application)
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  func registerForRemoteNotification(_ application: UIApplication) {
    if #available(iOS 10.0, *) {
      let center  = UNUserNotificationCenter.current()
      center.delegate = self
      center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
        if granted {
          application.registerForRemoteNotifications()
        }
      }
    }
    else {
      application.registerUserNotificationSettings(
        UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
      )
      application.registerForRemoteNotifications()
    }
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let deviceTokenString: String = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    NSLog("Device Token : %@", deviceTokenString)
    ChannelIO.initPushToken(deviceToken: deviceToken)
  }
  
  //when push was selected
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    ChannelIO.handlePushNotification(userInfo)
    completionHandler()
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    print("bb \(userInfo)")
  }
  
  //when push comes in only for foreground
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.sound, .alert, .badge])
  }
  
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("aa \(userInfo)")
    ChannelIO.handlePushNotification(userInfo) {
      completionHandler(.noData)
    }
  }

}

