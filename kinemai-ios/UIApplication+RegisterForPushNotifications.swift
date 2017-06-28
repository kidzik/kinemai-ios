//
//  UIApplication+RegisterForPushNotifications.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 23/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit
import UserNotifications

extension UIApplication
{
    static let KEY_wasUserAskedAboutPushNotifications = "KEY_USER_WAS_ASKED_ABOUT_PUSH_PERMISSIONS"
    
    var wasUserAskedAboutPushNotifications: Bool {
        let ud = UserDefaults.standard
        return ud.bool(forKey: UIApplication.KEY_wasUserAskedAboutPushNotifications)
    }
    
    func registerForPushNotifications()
    {
        if self.wasUserAskedAboutPushNotifications { return }
        
        Backend.registerNewUserIfNeeded { wasRegistered in
            if wasRegistered
            {
                Backend.authenticateLocalUser { wasAuthenticated in
                    if wasAuthenticated
                    {
                        let un = UNUserNotificationCenter.current()
                        un.requestAuthorization(
                            options: [.badge, .alert, .sound]
                            , completionHandler: { (granted, error) in }
                        )
                        
                        self.registerForRemoteNotifications()
                        
                        let ud = UserDefaults.standard
                        ud.set(true, forKey: UIApplication.KEY_wasUserAskedAboutPushNotifications)
                        ud.synchronize()
                    }
                }
            }
        }
    }
}
