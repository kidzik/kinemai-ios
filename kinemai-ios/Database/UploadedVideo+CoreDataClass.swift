//
//  UploadedVideo+CoreDataClass.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 18/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import Foundation
import CoreData


public class UploadedVideo: NSManagedObject
{
    class func findById(videoID: String) -> UploadedVideo?
    {
        if let result = self.mr_findFirst(byAttribute: "videoID", withValue: videoID)
        {
            return result
        }
        
        return nil
    }
    
    class func findAllStillProcessing() -> [UploadedVideo]
    {
        let status = NSNumber(value: ProcessingStatus.isProcessing.rawValue)
        
        if let results = self.mr_find(
            byAttribute: "processingStatus"
            , withValue: status) as? [UploadedVideo]
        {
            return results
        }
        
        return []
    }
}
