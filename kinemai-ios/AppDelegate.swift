//
//  AppDelegate.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 13/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit
import MagicalRecord
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.setupDatabase()
        self.authenticateLocalUser(completion: nil)
        VideoStatusUpdater.shared.updateVideoStatusIfNeeded()
        
        if application.wasUserAskedAboutPushNotifications
        {
            let un = UNUserNotificationCenter.current()
            un.requestAuthorization(
                options: [.badge, .alert, .sound]
                , completionHandler: { (granted, error) in }
            )
            application.registerForRemoteNotifications()
        }
        
        if let push = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        {
            NotificationReceiver.appJustLaunchedFromPushNotification(notification: push)
        }
        
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        Backend.userLogout()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        print("---- Device registered for Push Notifications ----")
        print("APNS TokenString: \(deviceTokenString)")
        
        Backend.sendApnsTokenToServer(apnsToken: deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("---- Failed to register for remote notifications ----")
        print("Error: '\(error.localizedDescription)'")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        NotificationReceiver.receivedPushWhileAppWasLaunched(notification: userInfo)
        completionHandler(.noData)
    }
    
    private func setupDatabase()
    {
        let modelURL = Bundle.main.url(forResource: "Kinemai", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)
        NSManagedObjectModel.mr_setDefaultManagedObjectModel(model)
        
        MagicalRecord.setupCoreDataStack(withStoreNamed: "Kinemai.sqlite")
        MagicalRecord.setLoggingLevel(.off)
    }
    
    private func authenticateLocalUser(completion: ((Bool) -> Void)? = nil)
    {
        Backend.registerNewUserIfNeeded { wasUserRegistered in
            
            if wasUserRegistered
            {
                Backend.authenticateLocalUser(completion: { wasAuthenticated in
                    completion?(wasAuthenticated)
                })
            }
            else
            {
                completion?(false)
            }
        }
    }
}

