//
//  AppDelegate.swift
//  mymedicos
//
//  Created by Devansh Saxena on 28/07/24.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // This is only needed if you are not using SceneDelegate
        if #available(iOS 13.0, *) {
            // SceneDelegate will handle window setup
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            let navigationController = UINavigationController(rootViewController: GetStartedViewController())
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            
            window?.overrideUserInterfaceStyle = .light

        }
        
        return true
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
