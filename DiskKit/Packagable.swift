//
//  Packagable.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-16.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public protocol Packagable {
    init(package: Package) throws
    func fill(package: Package) throws
}

public extension Packagable {
    
    public func makeFileWrapper(filename: String) throws -> FileWrapper {
        let package = Package(filename: filename, savedUrl: nil)
        try fill(package: package)
        return try package.makeFileWrapper()
    }
}
