//
//  SettingsViewController.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 27/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet weak var btnInfo: UIBarButtonItem!
    @IBOutlet weak var btnSurvey: UIButton!
    @IBOutlet weak var btnEmail: UIButton!
    
    @IBAction func btnInfoPressed()
    {
        UIApplication.shared.showOnboarding()
    }
    @IBAction func btnSurveyPressed(_ sender: UIButton) {
        let url = URL(string: "https://goo.gl/forms/ZQqf6nplgBoOBUpU2")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func btnEmailPressed(_ sender: UIButton) {
        let email = "hello@kinemai.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}
