//
//  NotificationReceiver.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 28/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit

class NotificationReceiver
{
    class func appJustLaunchedFromPushNotification(notification: [AnyHashable: Any])
    {
        VideoStatusUpdater.shared.updateVideoStatusIfNeeded()
        
        guard let video = self.videoFromNotification(push: notification) else { return }
    
        
        let window = UIApplication.shared.windows.first
        guard let tabVC = window?.rootViewController as? UITabBarController,
            let tabs = tabVC.viewControllers else { return }
        
        if tabs.count < 2 { return }
        
        guard let libraryNavVC = tabs[1] as? UINavigationController
            , let libraryVC = libraryNavVC.viewControllers.first as? LibraryListViewController else { return }
        
        tabVC.selectedIndex = 1
        libraryVC.performSegue(withIdentifier: "ShowLibraryItem", sender: video)
    }
    
    class func receivedPushWhileAppWasLaunched(notification: [AnyHashable: Any])
    {
        VideoStatusUpdater.shared.updateVideoStatusIfNeeded()
        
        guard let video = self.videoFromNotification(push: notification) else { return }
        
        let window = UIApplication.shared.windows.first
        guard let tabVC = window?.rootViewController as? UITabBarController,
            let tabs = tabVC.viewControllers else { return }
        
        if tabs.count < 2 { return }
        
        guard let libraryNavVC = tabs[1] as? UINavigationController else { return }

        
        let alert = UIAlertController(
            title: "Video is ready!"
            , message: "Your video has just finished processing."
            , preferredStyle: .alert
        )
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            
            libraryNavVC.popToRootViewController(animated: false)
            tabVC.selectedIndex = 1
            
            let activeVC = libraryNavVC.topViewController
            if let libraryListVC = activeVC as? LibraryListViewController
            {
                libraryListVC.performSegue(withIdentifier: "ShowLibraryItem", sender: video)
            }
        }
        
        alert.addAction(ok)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    private class func videoFromNotification(push: [AnyHashable: Any]) -> UploadedVideo?
    {
        print("\n\n")
        print("---- APP RECEIVED PUSH NOTIFICATION: ----")
        print("\(push)")
        print("---- NOTIFICATION END ----")
        
        guard let videoID = push["video_id"] as? String else { return nil }
        
        return UploadedVideo.findById(videoID: videoID)
    }
    
    private init() {}
}
