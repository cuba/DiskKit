//
//  SearchPathDirectory+Extensions.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-08.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

extension FileManager.SearchPathDirectory {
    /**
     * Returns URL constructed from specified directory
     */
    public var baseUrl: URL? {
        return FileManager.default.urls(for: self, in: .userDomainMask).first
    }
}
