//
//  AppDelegate.swift
//  Photos
//
//  Created by Владимир Кваша on 26.11.2020.
//

import UIKit

@main

// MARK: - AppDelegate

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Functions

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

