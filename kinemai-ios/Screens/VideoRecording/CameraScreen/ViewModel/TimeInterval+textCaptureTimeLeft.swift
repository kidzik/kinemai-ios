//
//  TimeInterval+textCaptureTimeLeft.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 17/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import Foundation

extension TimeInterval
{
    var textCaptureTimeLeft: String {
        
        let totalSeconds = Int(self + 0.5)
        if totalSeconds < 60
        {
            return String(format: "0:%02d", totalSeconds)
        }
        
        if totalSeconds < 3600
        {
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = (totalSeconds / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
