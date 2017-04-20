//
//  AppDelegate.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 4/6/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let manager = NetworkReachabilityManager(host: "www.rhizome.org")

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    let collects = UserDefaults.standard.object(forKey: "collects") as? NSDictionary;
    if (collects == nil) {
      UserDefaults.standard.set(NSDictionary(), forKey: "collects");
    }

    // Use Firebase library to configure APIs
    FIRApp.configure()

    IQKeyboardManager.sharedManager().enable = true
    IQKeyboardManager.sharedManager().enableAutoToolbar = false;

    let purple = UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
    UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "TimesNewRomanPS-BoldMT", size:32)!];
    UINavigationBar.appearance().tintColor = purple
    UINavigationBar.appearance().setTitleVerticalPositionAdjustment(4, for: .default)

    UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Times New Roman", size:18)!, NSForegroundColorAttributeName: purple], for: UIControlState.normal)
    UIBarButtonItem.appearance().tintColor = purple

    manager?.listener = { status in
      if status == .notReachable {
        if let navigationController = self.window?.rootViewController as? UINavigationController {
          navigationController.popToRootViewController(animated: true)
        }
      }
    }

    manager?.startListening()

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

class NavigationBar: UINavigationBar {
  override func layoutSubviews() {
    super.layoutSubviews()
    frame.size.height = 54
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var size = super.sizeThatFits(size)
    size.height = 54
    return size
  }
}

class Toolbar: UIToolbar {
  override func layoutSubviews() {
    super.layoutSubviews()
    frame.size.height = 54
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var size = super.sizeThatFits(size)
    size.height = 54
    return size
  }
}

