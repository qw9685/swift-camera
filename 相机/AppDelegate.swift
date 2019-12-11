//
//  AppDelegate.swift
//  相机
//
//  Created by mac on 2019/12/2.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        let rootViewController = UINavigationController.init(rootViewController: mainViewController())
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible();

        return true
    }
}

