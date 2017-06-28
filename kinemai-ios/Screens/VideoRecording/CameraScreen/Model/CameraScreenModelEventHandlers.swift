//
//  CameraScreenModelEventHandlers.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 18/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit
import NextLevel

class CameraScreenModelEventHandlers
{
    typealias EventHandlerType = ((Void) -> Void)
    
    let handlerConfigureCameraPreview: ((NextLevel) -> Void)
    
    let handlerBeforeFPSSetup: (Void) -> Void
    let handlerAfterFPSSetup: (Void) -> Void
    
    
    let handlerBeforeRecordingBegin: ((Void) -> Void)
    let handlerRecordingDidBegin: ((Void) -> Void)
    let handlerBeforeRecordingEnd: ((Void) -> Void)
    let handlerNewVideoClipReady: ((NextLevelClip) -> Void)
    
    
    init(model: CameraScreenModel
        , cameraVC: CameraViewController
        , handlerVideoClipReady: @escaping (NextLevelClip) -> Void
        )
    {
        self.handlerConfigureCameraPreview = {
            [weak cameraVC]
            nxt in
            guard let vc = cameraVC else { return }
            
            nxt.previewLayer.frame = vc.cameraPreview.bounds
            vc.cameraPreview.layer.addSublayer(nxt.previewLayer)
        }
        
        self.handlerBeforeFPSSetup = {
            [weak cameraVC] in
            guard let view = cameraVC?.view else { return }
            
            view.isUserInteractionEnabled = false
        }
        
        self.handlerAfterFPSSetup = {
            [weak cameraVC] in
            
            guard let view = cameraVC?.view else { return }
            
            view.isUserInteractionEnabled = true
        }
        
        self.handlerBeforeRecordingBegin = {
            [weak cameraVC] in
            guard let vc = cameraVC else { return }
            
            vc.navigationController?.tabBarController?.tabBar.isUserInteractionEnabled = false
        }
        
        self.handlerRecordingDidBegin = {}
        
        self.handlerBeforeRecordingEnd = {
            [weak cameraVC]
            videoClip in
            guard let vc = cameraVC else { return }
            
            vc.navigationController?.tabBarController?.tabBar.isUserInteractionEnabled = true
        }
        
        self.handlerNewVideoClipReady = handlerVideoClipReady
    }
}

