//
//  DiskUtility.swift
//  Example
//
//  Created by Jacob Sikorski on 2018-09-19.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
import DiskKit

class DiskUtility {
    static func clearDocuments() {
        let _ = try? Disk.clear(.documents)
    }
}
