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
    
    @IBAction func btnInfoPressed()
    {
        UIApplication.shared.showOnboarding()
    }
}
