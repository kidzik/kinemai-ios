//
//  LibraryItemViewController.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 15/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit

class LibraryItemViewController: UIViewController
{
    var video: UploadedVideo!
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.reloadVideoPage()
    }
    
    func reloadVideoPage()
    {
        DispatchQueue.main.async {
            let url = URL(string: "https://golf.kinemai.com/swing/" + self.video.videoID)!
            let request = URLRequest(url: url)
            self.webView.loadRequest(request)
        }
    }
}
