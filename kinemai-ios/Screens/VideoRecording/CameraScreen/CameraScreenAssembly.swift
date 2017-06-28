//
//  CameraScreenAssembly.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 18/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit
import NextLevel

class CameraScreenAssembly
{
    class func assemble(forVC vc: CameraViewController)
    {
        let model = CameraScreenModel()
        let viewModel = CameraScreenViewModel(model: model)
        
        vc.viewModel = viewModel
        vc.vcEventHandlers = CameraViewControllerEventHandlers(
            vc: vc
            , viewModel: viewModel
            , model: model
        )
        
        model.eventHandlers = CameraScreenModelEventHandlers(model: model, cameraVC: vc, handlerVideoClipReady: {
            [weak vc]
            videoClip in
            guard let vc = vc else { return }
            CameraScreenAssembly
                .processVideoClipTaken(video: videoClip, usingCameraVC: vc)
        })
    }
    
    private class func processVideoClipTaken(
        video: NextLevelClip
        , usingCameraVC vc: CameraViewController)
    {
        guard let _ = video.asset else
        {
            vc.showAlertFailedToTakeVideo()
            video.removeFile()
            return
        }
        
        var durationSec = Double(video.duration.value)
        durationSec /= Double(video.duration.timescale)
        
        print("---- Clip Duration sec: '\(durationSec)'")
        if durationSec < 3
        {
            vc.showAlertVideoClipTakenIsTooShort()
            video.removeFile()
            return
        }
        
        vc.performSegue(withIdentifier: "ShowFragmentSelection", sender: video)
    }
    
    private init() {}
}
