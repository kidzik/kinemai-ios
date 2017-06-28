//
//  CameraScreenModel+NextLevel delegates.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 18/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import NextLevel
import AVFoundation

// MARK: -
// MARK: NextLevelDelegate
extension CameraScreenModel: NextLevelDelegate
{
    func nextLevel(_ nextLevel: NextLevel, didUpdateAuthorizationStatus status: NextLevelAuthorizationStatus, forMediaType mediaType: String)
    {
        if mediaType != AVMediaTypeVideo { return }
        
        self.handleCameraAuthorizationStatus()
    }
    
    func nextLevelSessionDidStart(_ nextLevel: NextLevel)
    {
        self.setupMaximumFpsPossible()
        print("Session started. FPS: \(self.nxtLevel.frameRate)")
        
        self.nxtLevel.deviceDelegate = self
    }
    
    func nextLevelSessionDidStop(_ nextLevel: NextLevel)
    {
        self.nxtLevel.deviceDelegate = nil
    }
    
    func nextLevelSessionWasInterrupted(_ nextLevel: NextLevel)
    {
        self.stopRecording()
    }
    
    internal func setupMaximumFpsPossible()
    {
        let bounds = self.nxtLevel.previewLayer.bounds
        let dimensions = CMVideoDimensions(width: Int32(bounds.width), height: Int32(bounds.height))
        
        self.eventHandlers.handlerBeforeFPSSetup()
        
        for fps: CMTimeScale in [60, 120, 240]
        {
            print("---- Trying to set FPS '\(fps)' ----")
            self.nxtLevel.updateDeviceFormat(withFrameRate: fps, dimensions: dimensions)
        }
        
        self.eventHandlers.handlerAfterFPSSetup()
    }
}

// MARK: -
// MARK: NextLevelDeviceDelegate
extension CameraScreenModel: NextLevelDeviceDelegate
{
    func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel)
    {
        self.setupMaximumFpsPossible()
        print("Device changed. FPS: \(self.nxtLevel.frameRate)")
    }
}

// MARK: -
// MARK: NextLevelVideoDelegate
extension CameraScreenModel: NextLevelVideoDelegate
{
    func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession)
    {
        self.currentRecordingDuration = 0
        self.videoCaptureTimeLeftSec.next(self.maximumVideoLengthSec)
        self.wasLatestTimestampInitialized = false
        
        self.isRecordingInProgress.next(true)
        
        self.timerUpdateCaptureTimeLeft = Timer.scheduledTimer(
            timeInterval: self.updateCaptureTimeLeftPropertyEachSec
            , target: self
            , selector: #selector(timerUpdateCaptureTimeLeftFired)
            , userInfo: nil
            , repeats: true
        )
        
        self.eventHandlers.handlerRecordingDidBegin()
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession)
    {
        self.eventHandlers.handlerNewVideoClipReady(clip)
    }
}
