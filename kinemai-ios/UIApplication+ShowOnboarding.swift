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
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static let KEY_didUserSeeOnboarding = "KEY_USER_SAW_ONBOARDING" // + randomString(length: 10)
    
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
            title: "Welcome to Kinemai Golf"
            , body: "Kinemai will help you swing like a PRO.\n\n" +
            "Just record your swing from one of the two angles.\n\n" +
            "Swipe to the next screens for details.\n"
            , image: nil
            , buttonText: nil
            , action: nil
        )
        
        let pageTwo = OnboardingContentViewController(
            title: "Face on"
            , body: "Put the phone in front.\n\n" +
            "Kinemai will analyze your pose and the strike."
            , image: UIImage(named: "Onboarding/faceon")
            , buttonText: nil
            , action: nil
        )
        
        let pageThree = OnboardingContentViewController(
            title: "Down the line"
            , body: "Put the phone on side.\n\n" +
            "Kinemai will analyze your alignment and your swing path."
            , image: UIImage(named: "Onboarding/downtheline")
            , buttonText: nil
            , action: nil
        )
        
        pageOne.topPadding = 50
        pageOne.iconHeight = 0
        pageOne.underIconPadding = 10
        
        pageTwo.topPadding = 35
        pageTwo.iconHeight = 265
        pageTwo.iconWidth = 200
        pageTwo.underIconPadding = 10
        pageTwo.underTitlePadding = 5
        
        pageThree.topPadding = 35
        pageThree.iconHeight = 265
        pageThree.iconWidth = 180
        pageThree.underIconPadding = 10
        pageThree.underTitlePadding = 5


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
        onboarding.skipButton.setTitle("Let's go", for: .normal)
        
        tabVC.present(onboarding, animated: true, completion: nil)
    }
}
