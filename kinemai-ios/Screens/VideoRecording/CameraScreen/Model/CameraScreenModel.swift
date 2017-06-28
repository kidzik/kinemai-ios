//
//  CameraScreenModel.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 17/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import ReactiveKit
import NextLevel
import AVFoundation

class CameraScreenModel: NSObject
{
    var eventHandlers: CameraScreenModelEventHandlers!
    
    let nxtLevel = NextLevel.shared
    let maximumVideoLengthSec: TimeInterval = 30
    let updateCaptureTimeLeftPropertyEachSec: TimeInterval = 0.5
    
    private(set) var isRecordingInProgress: Property<Bool>!
    private(set) var videoCaptureTimeLeftSec: Property<TimeInterval>!
    
    
    internal var wasLatestTimestampInitialized = false
    internal var latestTimestamp: TimeInterval = 0
    internal var currentRecordingDuration: TimeInterval = 0
    
    internal var timerUpdateCaptureTimeLeft: Timer? = nil
    internal var updateRecordingDuration: CADisplayLink!
    
    override init()
    {
        super.init()
        
        self.isRecordingInProgress = Property(false)
        self.videoCaptureTimeLeftSec = Property(0)
        
        self.nxtLevel.captureMode = .videoWithoutAudio
        self.nxtLevel.delegate = self
        self.nxtLevel.videoDelegate = self
        
        
        self.updateRecordingDuration = CADisplayLink(
            target: self
            , selector: #selector(updateCurrentRecordingDuration)
        )
        self.updateRecordingDuration.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
    }
}

// MARK: -
// MARK: UI actions
extension CameraScreenModel
{
    @objc public func switchCameras()
    {
        let cDevice = self.nxtLevel.devicePosition
        self.nxtLevel.devicePosition = (cDevice == .back) ? .front : .back
    }
    
    @objc public func startRecording()
    {
        self.eventHandlers.handlerBeforeRecordingBegin()
        
        self.nxtLevel.record()
    }
    
    @objc public func stopRecording()
    {
        self.eventHandlers.handlerBeforeRecordingEnd()
        
        self.timerUpdateCaptureTimeLeft?.invalidate()
        self.timerUpdateCaptureTimeLeft = nil
        
        self.isRecordingInProgress.next(false)
        
        self.nxtLevel.pause()
    }
    
    @objc public func stopSession()
    {
        self.nxtLevel.stop()
    }
}

// MARK: -
// MARK: Timers management
extension CameraScreenModel
{
    @objc internal func updateCurrentRecordingDuration()
    {
        if false == self.isRecordingInProgress.value { return }
        
        let cTime = self.updateRecordingDuration.timestamp
        if false == self.wasLatestTimestampInitialized
        {
            self.latestTimestamp = cTime
            self.wasLatestTimestampInitialized = true
            return
        }
        
        let delta = cTime - self.latestTimestamp
        self.latestTimestamp = cTime
        self.currentRecordingDuration += delta
        
        if self.currentRecordingDuration >= self.maximumVideoLengthSec
        {
            self.stopRecording()
        }
    }
    
    
    @objc internal func timerUpdateCaptureTimeLeftFired()
    {
        var timeLeft = self.maximumVideoLengthSec
        timeLeft -= self.currentRecordingDuration
        
        if timeLeft < 0
        {
            timeLeft = 0
        }
        
        self.videoCaptureTimeLeftSec.value = timeLeft
    }
}

// MARK: -
// MARK: Authorization status
extension CameraScreenModel
{
    func handleCameraAuthorizationStatus()
    {
        let authStatus = self.nxtLevel.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .authorized
        {
            self.startCameraPreview()
        }
        else
        {
            self.nxtLevel.requestAuthorization(forMediaType: AVMediaTypeVideo)
        }
    }
    
    private func startCameraPreview()
    {
        self.configurePreviewSublayerIfNeeded()
        
        do
        {
            try self.nxtLevel.start()
        }
        catch let exc as NextLevelError
        {
            switch exc
            {
            case .started:
                break
            default:
                print("---- Failed to start camera preview: '\(exc.localizedDescription)' ----")
                print("'\(exc.localizedDescription)'")
            }
        }
        catch let error
        {
            print("---- Failed to start camera preview: '\(error.localizedDescription)' ----")
        }
    }
    
    private func configurePreviewSublayerIfNeeded()
    {
        if nil == self.nxtLevel.previewLayer.superlayer
        {
            self.eventHandlers.handlerConfigureCameraPreview(self.nxtLevel)
        }
    }
}
