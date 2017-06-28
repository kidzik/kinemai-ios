//
//  NextLevelDeviceDelegate+DefaultImplementations.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 17/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import NextLevel
import AVFoundation

extension NextLevelDeviceDelegate
{
    // position, orientation
    func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {}
    func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {}
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {}
    
    // format
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDeviceFormat) {}
    
    // aperture
    func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {}
    
    // focus, exposure, white balance
    func nextLevelWillStartFocus(_ nextLevel: NextLevel) {}
    func nextLevelDidStopFocus(_  nextLevel: NextLevel) {}
    
    func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {}
    func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {}
    
    func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {}
    func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {}
}
