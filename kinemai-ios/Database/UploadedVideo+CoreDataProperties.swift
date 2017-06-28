//
//  UploadedVideo+CoreDataProperties.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 18/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import Foundation
import CoreData


extension UploadedVideo {

    @objc public enum ProcessingStatus: Int16, RawRepresentable
    {
        case isProcessing = 0
        case Processed = 16
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UploadedVideo> {
        return NSFetchRequest<UploadedVideo>(entityName: "UploadedVideo")
    }

    @NSManaged public var videoID: String
    @NSManaged public var processingStatus: ProcessingStatus
    @NSManaged public var creationDate: NSDate
    @NSManaged public var thumbnailFileName: String?

}

