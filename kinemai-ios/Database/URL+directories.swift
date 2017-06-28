//
//  URL+directories.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 18/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import Foundation

extension URL
{
    static var docsDirectory: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docs = paths[0]
        return URL(fileURLWithPath: docs)
    }
}
