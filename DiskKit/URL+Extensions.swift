//
//  URL+Extensions.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-30.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

extension URL {
    func isParent(of url: URL) -> Bool {
        return url.absoluteString.hasPrefix(absoluteString)
    }
}
