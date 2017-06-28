//
//  UIApplication+ShowOnboarding.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 28/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit
import Onboard

extension UIApplication
{
    static let KEY_didUserSeeOnboarding = "KEY_USER_SAW_ONBOARDING"
    
    var didUserSeeOnboarding: Bool {
        let ud = UserDefaults.standard
        return ud.bool(forKey: UIApplication.KEY_didUserSeeOnboarding)
    }
    
    func showOnboarding()
    {
        guard let window = self.windows.first else { return }
        
        guard let tabVC = window.rootViewController as? UITabBarController else { return }
        
        let ud = UserDefaults.standard
        ud.set(true, forKey: UIApplication.KEY_didUserSeeOnboarding)
        ud.synchronize()
        
        
        let pageOne = OnboardingContentViewController(
            title: "Page One"
            , body: nil
            , image: nil
            , buttonText: nil
            , action: nil
        )
        
        let pageTwo = OnboardingContentViewController(
            title: "Page Two"
            , body: nil
            , image: nil
            , buttonText: nil
            , action: nil
        )
        
        let pageThree = OnboardingContentViewController(
            title: "Page Three"
            , body: nil
            , image: nil
            , buttonText: nil
            , action: nil
        )
        
        let backgroundImage = UIImage(named: "Onboarding/background")!
        let onboarding = OnboardingViewController(
            backgroundImage: backgroundImage
            , contents: [pageOne, pageTwo, pageThree]
        )!
        
        onboarding.swipingEnabled = true
        onboarding.allowSkipping = true
        onboarding.skipHandler = {
            onboarding.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        tabVC.present(onboarding, animated: true, completion: nil)
    }
}
