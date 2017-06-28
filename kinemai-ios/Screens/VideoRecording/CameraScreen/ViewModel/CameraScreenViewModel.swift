//
//  CameraScreenViewModel.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 17/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import ReactiveKit
import Bond

class CameraScreenViewModel
{
    private(set) var isBtnStartRecordingHidden: Property<Bool>!
    private(set) var isBtnSwitchCamerasHidden: Property<Bool>!
    
    private(set) var isBtnStopRecordingHidden: Property<Bool>!
    private(set) var isLabelCaptureTimeLeftHidden: Property<Bool>!
    
    private(set) var labelCaptureTimeLeftText: Property<String>!
    
    private let model: CameraScreenModel
    private let disposeBag = DisposeBag()
    
    
    init(model: CameraScreenModel)
    {
        self.model = model
        
        self.initProperties()
        self.setupBindings()
    }
    
    private func initProperties()
    {
        let isRecording = model.isRecordingInProgress.value
        
        self.isBtnStartRecordingHidden = Property(isRecording)
        self.isBtnSwitchCamerasHidden = Property(isRecording)
        
        self.isBtnStopRecordingHidden = Property(!isRecording)
        self.isLabelCaptureTimeLeftHidden = Property(!isRecording)
        
        let strTimeLeft = model.videoCaptureTimeLeftSec.value.textCaptureTimeLeft
        self.labelCaptureTimeLeftText = Property(strTimeLeft)
    }
    
    private func setupBindings()
    {
        self.model.isRecordingInProgress
            .bind(to: self.isBtnStartRecordingHidden)
            .dispose(in: disposeBag)
        
        self.model.isRecordingInProgress
            .bind(to: self.isBtnSwitchCamerasHidden)
            .dispose(in: self.disposeBag)
        
        self.model.isRecordingInProgress
            .map { !$0 }
            .bind(to: self.isBtnStopRecordingHidden)
            .dispose(in: self.disposeBag)
        
        self.model.isRecordingInProgress
            .map { !$0 }
            .bind(to: self.isLabelCaptureTimeLeftHidden)
            .dispose(in: self.disposeBag)
        
        self.model.videoCaptureTimeLeftSec
            .map { $0.textCaptureTimeLeft }
            .bind(to: self.labelCaptureTimeLeftText)
            .dispose(in: self.disposeBag)
    }
}
