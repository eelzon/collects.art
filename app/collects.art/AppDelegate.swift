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
  let manager = NetworkReachabilityManager()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Use Firebase library to configure APIs
    FIRApp.configure()

    // custom scrollview behavior + done button entry
    let attributes = [NSFontAttributeName: UIFont(name: "Times New Roman", size:18)!]
    let keyboardManager = IQKeyboardManager.sharedManager()
    keyboardManager.toolbarTintColor = UIColor.linkPurple
    keyboardManager.enable = true
    keyboardManager.shouldPlayInputClicks = false
    IQBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
    IQBarButtonItem.appearance().tintColor = UIColor.linkPurple

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

extension UIColor {

  @nonobjc class var linkBlue: UIColor {
    return UIColor(colorLiteralRed: 0, green: 0, blue: 238/256, alpha: 1.0)
  }

  @nonobjc class var linkPurple: UIColor {
    return UIColor(colorLiteralRed: 85/256, green: 26/256, blue: 139/256, alpha: 1.0)
  }

}
