//
//  DisabledSwipeBackNavigationController.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 18/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit

class DisabledSwipeBackNavigationController: UINavigationController
{
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
}
