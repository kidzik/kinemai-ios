//
//  VideoStatusUpdater.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 23/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import MagicalRecord

class VideoStatusUpdater
{
    static let shared = VideoStatusUpdater()
    
    private var timer: Timer? = nil
    
    func updateVideoStatusIfNeeded()
    {
        let allVideosStillProcessing = UploadedVideo.findAllStillProcessing()
        if allVideosStillProcessing.count == 0 { return }
        
        
        print("---- Videos, which require status update: ----")
        for v in allVideosStillProcessing
        {
            print("\(v.videoID)")
        }
        
        Backend.allVideosByLocalUser { resultsResponse in
            guard let resultsResponse = resultsResponse else { return }
            
            for elem in resultsResponse
            {
                if let id = elem["id"] as? String,
                    let status = elem["status"] as? String,
                    let video = UploadedVideo.findById(videoID: id)
                {
                    if status == "p"
                    {
                        video.processingStatus = UploadedVideo.ProcessingStatus.isProcessing
                    }
                    else if status == "d"
                    {
                        print("---- Status: finished processing")
                        video.processingStatus = UploadedVideo.ProcessingStatus.Processed
                    }
                }
            }
            
            let ctx = NSManagedObjectContext.mr_default()
            ctx.mr_saveToPersistentStoreAndWait()
        }
    }
    
    private init()
    {
        self.timer = Timer.scheduledTimer(
            timeInterval: 30 * 60
            , target: self
            , selector: #selector(updateTimerFired)
            , userInfo: nil
            , repeats: true
        )
    }
    
    @objc fileprivate func updateTimerFired()
    {
        self.updateVideoStatusIfNeeded()
    }
    
    deinit
    {
        self.timer?.invalidate()
        self.timer = nil
    }
}
