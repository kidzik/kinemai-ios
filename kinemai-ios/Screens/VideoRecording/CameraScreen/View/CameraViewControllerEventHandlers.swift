//
//  CameraViewControllerEventHandlers.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 17/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit

class CameraViewControllerEventHandlers
{
    typealias EventHandlerType = ((Void) -> Void)
    
    let handleAfterViewDidLoad: EventHandlerType
    let handleAfterViewDidAppear: EventHandlerType
    let handleAfterViewWillDisappear: EventHandlerType
    
    init(vc: CameraViewController
        , viewModel: CameraScreenViewModel
        , model: CameraScreenModel
        )
    {
        self.handleAfterViewDidLoad = {
            [weak vc, weak model] in
            guard let vc = vc, let model = model else { return }
            
            vc.btnSwitchCameras.reactive.tap.observeNext {
                [weak model] in
                guard let model = model else { return }
                
                model.switchCameras()
            }.dispose(in: vc.disposeBag)
            
            vc.btnStartRecording.reactive.tap.observeNext {
                [weak model] in
                guard let model = model else { return }
                
                model.startRecording()
            }.dispose(in: vc.disposeBag)
            
            vc.btnStopRecording.reactive.tap.observeNext {
                [weak model] in
                guard let model = model else { return }
                
                model.stopRecording()
            }.dispose(in: vc.disposeBag)
        }
        
        
        self.handleAfterViewDidAppear = {
            [weak model] in
            guard let model = model else { return }
            
            let app = UIApplication.shared
            if app.didUserSeeOnboarding == false
            {
                app.showOnboarding()
            }
            else
            {
                model.handleCameraAuthorizationStatus()
            }
        }
        
        
        self.handleAfterViewWillDisappear = {
            [weak model] in
            guard let model = model else { return }
            
            model.stopSession()
        }
    }
}
